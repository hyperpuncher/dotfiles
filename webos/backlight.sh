#!/bin/sh

hour=$(luna-send -n 1 luna://com.webos.service.systemservice/time/getSystemTime '{}' -q 'localtime.hour' | awk -F ':' '{print $2}' | xargs)

if [ "$hour" -gt 18 ] || [ "$hour" -lt 6 ]; then
	luna-send -n 1 luna://com.webos.settingsservice/setSystemSettings '{ "category": "picture", "notifySelf": false, "settings": { "pictureMode": "expert2" } }'
else
	luna-send -n 1 luna://com.webos.settingsservice/setSystemSettings '{ "category": "picture", "notifySelf": false, "settings": { "pictureMode": "expert1" } }'
fi
