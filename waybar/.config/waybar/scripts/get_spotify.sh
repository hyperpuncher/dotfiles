#!/bin/bash

if [ -n "$(playerctl status)" ]; then

    media=$(playerctl metadata -f "{{artist}} - {{title}}")
    media_chars=$(echo "$media" | wc -c)

    if [[ $media_chars -gt 32 ]]; then
        media=$(echo "$media" | cut -c -32)
        media+="..."
    fi

    if [ "$(playerctl status)" = "Playing" ]; then
        song_status=''
    else
        song_status=''
    fi

    echo -e "$song_status $media"
fi
