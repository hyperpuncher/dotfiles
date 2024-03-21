#!/usr/bin/env dash

kb_names="bastard-keyboards-charybdis-mini-(3x6)-pro-micro hyperpuncher-kanariyoi"

ru_layout_apps="org.telegram.desktop"

devices=$(hyprctl devices)

for name in ${kb_names}; do
	if echo "$devices" | grep -q "$name"; then
		active_keyboard="$name"
		break
	fi
done

handle() {
	case $1 in
	activewindow\>*)
		activewindow=$(echo "$1" | sed -n 's/^activewindow>>\([^,]*\).*/\1/p')

		case "$ru_layout_apps" in
		*"$activewindow"*)
			layout=1
			;;
		*)
			layout=0
			;;
		esac

		echo "switchxkblayout $active_keyboard $layout" | socat - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket.sock

		;;
	esac
}

socat -U - UNIX-CONNECT:/tmp/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock |
	while read -r line; do handle "$line"; done
