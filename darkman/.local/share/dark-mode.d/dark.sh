#!/usr/bin/env dash

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

kvantummanager --set ColloidDark
sed -i 's/icon_theme=.*/icon_theme=Papirus-Dark/' ~/.config/qt6ct/qt6ct.conf
export QT_QPA_PLATFORMTHEME=qt6ct

ln -fs ~/dotfiles/rofi/.config/rofi/themes/dark.rasi ~/.config/rofi/theme.rasi

hyprctl dispatch exec "swaybg -i /home/igor/Pictures/wallpapers/dark.avif"

pkill Telegram
hyprctl dispatch exec "Telegram"

sleep 1
pkill -o swaybg
