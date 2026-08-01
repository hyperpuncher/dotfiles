#!/usr/bin/env dash

case "$1" in
light | dark)
	qs ipc call shell setTheme "$1" >/dev/null 2>&1 || true
	;;
esac
