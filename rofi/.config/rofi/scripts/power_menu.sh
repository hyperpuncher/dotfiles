#!/usr/bin/env dash

cleanup() {
	hyprctl -q --batch "$(hyprctl -j clients | jq -j '.[] | "dispatch closewindow pid:\(.pid);"')"
	cliphist wipe
}

case $1 in
"shutdown")
	cleanup
	systemctl poweroff
	;;
"reboot")
	cleanup
	systemctl reboot
	;;
"logout")
	case "$XDG_CURRENT_DESKTOP" in
	"niri")
		niri msg action quit
		;;
	"Hyprland")
		hyprctl dispatch exit
		;;
	esac
	;;
esac

if [ $# -gt 0 ]; then
	exit 0
fi

printf "shutdown\nreboot\nlogout"
