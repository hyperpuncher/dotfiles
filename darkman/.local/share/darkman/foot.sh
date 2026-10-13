#!/usr/bin/env dash

set -eu

themes="$HOME/.config/foot/themes"

case "$1" in
light)
	target=light.ini
	signal=USR2
	;;
dark)
	target=dark.ini
	signal=USR1
	;;
*) exit 0 ;;
esac

mkdir -p "$themes"
ln -sfn "$target" "$themes/.colorscheme.tmp"
mv -Tf "$themes/.colorscheme.tmp" "$themes/colorscheme.ini"

pkill -"$signal" -x foot 2>/dev/null || true
pkill -"$signal" -x footclient 2>/dev/null || true
