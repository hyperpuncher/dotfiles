#!/usr/bin/env dash

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Light'

kvantummanager --set Colloid
sed -i 's/icon_theme=.*/icon_theme=Papirus/' ~/.config/qt6ct/qt6ct.conf
export QT_QPA_PLATFORMTHEME=qt6ct

hyprctl dispatch exec "swaybg -m fill -i /home/igor/Pictures/wallpapers/gradient_light.avif"
hyprctl dispatch exec "swaybg -i /home/igor/Pictures/wallpapers/mask_vertical_4k.png"
sleep 1
pkill -o swaybg
pkill -o swaybg
