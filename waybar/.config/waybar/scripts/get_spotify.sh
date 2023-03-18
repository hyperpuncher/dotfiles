#!/bin/bash
player_status=$(playerctl status)

if [[ $player_status = "" ]]
then
    song_status='Spotify '
else
    media=$(playerctl metadata -f "{{artist}} - {{title}}")
    if [[ $player_status = "Playing" ]]
    then
        song_status=''
    else
        song_status=''
    fi
    echo -e "$song_status $media"
fi
