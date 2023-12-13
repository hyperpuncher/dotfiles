#!/bin/bash

curl https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js -o ~/.mozilla/firefox/*.default-release/user.js &&
    cat ~/dotfiles/firefox/user.js >>~/.mozilla/firefox/*.default-release/user.js
