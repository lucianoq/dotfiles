#!/bin/bash

cachedir=~/.cache/rbn
cachefile=${0##*/}-$1
cachefileraw=${0##*/}-$1.raw

if [ ! -d $cachedir ]; then
    mkdir -p $cachedir
fi

if [ ! -f $cachedir/$cachefile ]; then
    touch $cachedir/$cachefile
    touch $cachedir/$cachefileraw
fi

# Save current IFS
SAVEIFS=$IFS
# Change IFS to new line.
IFS=$'\n'

cacheage=$(($(date +%s) - $(stat -c '%Y' "$cachedir/$cachefile")))
if [ $cacheage -gt 1740 ] || [ ! -s $cachedir/$cachefile ]; then
    # Download weather info
    curl -o $cachedir/$cachefileraw -s https://en.wttr.in/$1\?0qnT 2>&1

    data=($(cat $cachedir/$cachefileraw))
    echo ${data[0]} | cut -f1 -d, > $cachedir/$cachefile
    echo ${data[1]} | sed -E 's/^.{15}//' >> $cachedir/$cachefile
    echo ${data[2]} | sed -E 's/^.{15}//' >> $cachedir/$cachefile
fi

weather=($(cat $cachedir/$cachefile))

# Restore IFSClear
IFS=$SAVEIFS

temperature=$(echo ${weather[2]} | sed -E 's/([[:digit:]]+)\.\./\1 to /g')

#echo ${weather[1]##*,}

# https://fontawesome.com/icons?s=solid&c=weather
case $(echo ${weather[1]##*,} | tr '[:upper:]' '[:lower:]') in
"clear" | "sunny")
    condition=""
    ;;
"partly cloudy")
    condition=""
    ;;
"cloudy")
    condition=""
    ;;
"overcast")
    condition=""
    ;;
"mist" | "fog" | "freezing fog")
    condition=""
    ;;
"patchy rain possible" | "patchy light drizzle" | "light drizzle" | "patchy light rain" | "light rain" | "light rain shower" | "rain")
    condition=""
    ;;
"moderate rain at times" | "moderate rain" | "heavy rain at times" | "heavy rain" | "moderate or heavy rain shower" | "torrential rain shower" | "rain shower")
    condition=""
    ;;
"patchy snow possible" | "patchy sleet possible" | "patchy freezing drizzle possible" | "freezing drizzle" | "heavy freezing drizzle" | "light freezing rain" | "moderate or heavy freezing rain" | "light sleet" | "ice pellets" | "light sleet showers" | "moderate or heavy sleet showers")
    condition=""
    ;;
"blowing snow" | "moderate or heavy sleet" | "patchy light snow" | "light snow" | "light snow showers")
    condition=""
    ;;
"blizzard" | "patchy moderate snow" | "moderate snow" | "patchy heavy snow" | "heavy snow" | "moderate or heavy snow with thunder" | "moderate or heavy snow showers")
    condition=""
    ;;
"thundery outbreaks possible" | "patchy light rain with thunder" | "moderate or heavy rain with thunder" | "patchy light snow with thunder")
    condition=""
    ;;
*)
    condition=""
    echo -e "{\"text\":\""$condition"\", \"alt\":\""${weather[0]}"\", \"tooltip\":\""${weather[0]}: $temperature ${weather[1]}"\"}"
    ;;
esac

# echo -e "{\"text\":\""$condition $temperature"\", \"alt\":\""${weather[0]}"\", \"tooltip\":\""${weather[0]}: $temperature ${weather[1]}"\"}"

tooltip=$(cat $cachedir/$cachefileraw | sed -r 's/\\/\\\\/g' | sed -r 's/"/\\"/g' | awk '{printf "%s\\n", $0}' )
cat << EOF
{"text":"${weather[0]} $condition  $temperature", "tooltip": "$tooltip"}
EOF