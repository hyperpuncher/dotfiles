#!/usr/bin/env dash

ru_layout_apps="org.telegram.desktop"

keyboard=$(hyprctl devices | grep keyboard)

handle() {
	case $1 in
	activewindow\>*)
		activewindow=$(echo "$1" | sed -n 's/^activewindow>>\([^,]*\).*/\1/p')

		layout=0

		if echo "$activewindow" | grep -qE "$ru_layout_apps"; then
			layout=1
		fi

		echo "switchxkblayout $keyboard $layout" | socat - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket.sock

		;;
	esac
}

socat -U - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock |
	while read -r line; do handle "$line"; done
