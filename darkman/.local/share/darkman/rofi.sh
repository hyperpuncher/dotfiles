#!/usr/bin/env dash

THEME=

case "$1" in
light)
	THEME=light
	;;
dark)
	THEME=dark
	;;
esac

ln -sf ~/dotfiles/rofi/.config/rofi/themes/$THEME.rasi ~/.config/rofi/theme.rasi
