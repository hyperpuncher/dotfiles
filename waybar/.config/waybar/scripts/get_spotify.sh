#!/bin/bash
media=$(playerctl metadata -f "{{artist}} - {{title}}")
player_status=$(playerctl status)

if [[ $player_status = "Playing" ]]
then
    song_status=''
elif [[ $player_status = "Paused" ]]
then
    song_status=''
else
    song_status='Spotify '
fi

echo -e "$song_status $media"
