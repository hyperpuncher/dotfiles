#!/usr/bin/env dash

ICON_THEME=
KVANTUM_THEME=

case "$1" in
light)
	ICON_THEME=Papirus-Light
	KVANTUM_THEME=Colloid
	;;
dark)
	ICON_THEME=Papirus-Dark
	KVANTUM_THEME=ColloidDark
	;;
esac

kvantummanager --set "$KVANTUM_THEME"
sed -i "s/icon_theme=.*/icon_theme=$ICON_THEME/" ~/.config/qt6ct/qt6ct.conf
