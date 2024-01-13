#!/usr/bin/env sh

CONFIG=$(
	cd ~/.mozilla/firefox/*default-release &&
		pwd || exit
)/user.js

curl https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js >"$CONFIG" &&
	cat ~/dotfiles/firefox/user.js >>"$CONFIG"
