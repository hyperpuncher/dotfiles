#!/usr/bin/env dash

case $1 in
"shutdown")
	systemctl poweroff
	;;
"reboot")
	systemctl reboot
	;;
"logout")
	case "$XDG_CURRENT_DESKTOP" in
	"niri")
		niri msg action quit
		;;
	"hyprland")
		hyprctl dispatch exit
		;;
	esac
	;;
esac

if [ $# -gt 0 ]; then
	exit 0
fi

printf "shutdown\nreboot\nlogout"
