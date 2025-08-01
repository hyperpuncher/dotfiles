#!/usr/bin/env dash

case $1 in
"shutdown")
	systemctl poweroff
	;;
"reboot")
	systemctl reboot
	;;
"logout")
	uwsm stop
	;;
esac

if [ $# -gt 0 ]; then
	exit 0
fi

printf "shutdown\nreboot\nlogout"
