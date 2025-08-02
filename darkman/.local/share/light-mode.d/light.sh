#!/usr/bin/env dash

runapp swaybg -i /home/igor/Pictures/wallpapers/light.avif
[ $(pgrep -c swaybg) -gt 1 ] && pkill -o swaybg

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'

kvantummanager --set Colloid
sed -i 's/icon_theme=.*/icon_theme=Papirus/' ~/.config/qt6ct/qt6ct.conf
export QT_QPA_PLATFORMTHEME=qt6ct

ln -fs ~/dotfiles/rofi/.config/rofi/themes/light.rasi ~/.config/rofi/theme.rasi

pkill Telegram
runapp Telegram
