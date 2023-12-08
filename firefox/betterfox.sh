#!/bin/bash

curl https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js -o betterfox.js &&
    cp ~/dotfiles/firefox/betterfox.js ~/.mozilla/firefox/*.default-release/user.js &&
    cat ~/dotfiles/firefox/user.js >>~/.mozilla/firefox/*.default-release/user.js
