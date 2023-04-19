#!/bin/bash

wakeup=$(( 6 * 60 ))
sunset=$(( 19 * 60 ))
night=$(( 22 * 60 ))

color_day=65
color_night=25

while true; do

    current_hour=$(date +%k)
    current_minutes=$(date +%M)
    current_time=$(( current_hour * 60 + current_minutes ))

    if (( current_time >= wakeup && current_time < sunset )); then
        color_temp=$color_day

    elif (( current_time >= sunset && current_time < night )); then
        range=$(( night - sunset ))
        percent=$(echo "($current_time - $sunset) / $range" | bc -l )
        color_temp=$(echo "$color_day - (($color_day - $color_night) * $percent)" | bc -l )
        color_temp=$(printf "%.0f" "$color_temp")

    else
        color_temp=$color_night
    fi

    sed -i "s/temperature = [0-9][0-9]/temperature = $color_temp/" ~/dotfiles/hypr_home/.config/hypr/night_light.glsl
    echo "$color_temp"

    sleep 90
done
