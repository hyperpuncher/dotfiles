#!/bin/sh

choice=$(printf "Shutdown\nReboot\nLogout" | rofi -dmenu -i -p "Power")

case $choice in
"Shutdown")
	cliphist wipe && systemctl poweroff
	;;
"Reboot")
	systemctl reboot
	;;
"Logout")
	hyprctl dispatch exit 0
	;;
esac
