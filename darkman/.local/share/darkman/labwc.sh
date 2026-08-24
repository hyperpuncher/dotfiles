#!/usr/bin/env dash

set -eu

data_home=${XDG_DATA_HOME:-"$HOME/.local/share"}
themes="$data_home/themes"

case "$1" in
light) target=light ;;
dark) target=dark ;;
*) exit 0 ;;
esac

mkdir -p "$themes"
ln -sfn "$target" "$themes/.labwc.tmp"
mv -Tf "$themes/.labwc.tmp" "$themes/labwc"
pkill -HUP -x labwc 2>/dev/null || true
