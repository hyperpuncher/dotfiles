#!/usr/bin/env dash

ru_layout_apps="org.telegram.desktop|signal"

kb_names="zmk-project-ikiosuru-keyboard
bastard-keyboards-charybdis-mini-(3x6)-pro-micro
hyperpuncher-noob-keyboard"

handle() {
	case $1 in
	activewindow\>*)
		activewindow=$(echo "$1" | sed -n 's/^activewindow>>\([^,]*\).*/\1/p')

		layout=0

		if echo "$activewindow" | grep -iqE "$ru_layout_apps"; then
			layout=1
		fi

		for keyboard in $kb_names; do
			echo "switchxkblayout $keyboard $layout" | socat - UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket.sock
		done

		;;
	esac
}

socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock |
	while read -r line; do handle "$line"; done
