#!/bin/bash

cp ~/dotfiles/firefox/betterfox.js ~/.mozilla/firefox/*.default-release/user.js
cat ~/dotfiles/firefox/user.js >>~/.mozilla/firefox/*.default-release/user.js
