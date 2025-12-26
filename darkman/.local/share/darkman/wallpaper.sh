#!/usr/bin/env dash

WALLPAPER=

case "$1" in
light)
	WALLPAPER=/home/igor/Pictures/wallpapers/light.avif
	;;
dark)
	WALLPAPER=/home/igor/Pictures/wallpapers/dark.avif
	;;
esac

runapp swaybg -i $WALLPAPER
[ $(pgrep -c swaybg) -gt 1 ] && sleep 1 && pkill -o swaybg
