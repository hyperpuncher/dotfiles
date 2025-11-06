#!/usr/bin/env dash

MODE=
GTK_THEME=
ICON_THEME=

case "$1" in
light)
	MODE=light
	GTK_THEME=adw-gtk3
	ICON_THEME=Papirus-Light
	;;
dark)
	MODE=dark
	GTK_THEME=adw-gtk3-dark
	ICON_THEME=Papirus-Dark
	;;
esac

gsettings set org.gnome.desktop.interface gtk-theme "$GTK_THEME"
gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE"
gsettings set org.gnome.desktop.interface icon-theme "$ICON_THEME"
