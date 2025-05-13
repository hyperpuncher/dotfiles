#!/usr/bin/env dash

gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'

kvantummanager --set ColloidDark
sed -i 's/icon_theme=.*/icon_theme=Papirus-Dark/' ~/.config/qt6ct/qt6ct.conf
export QT_QPA_PLATFORMTHEME=qt6ct

ln -fs ~/dotfiles/rofi/.config/rofi/themes/dark.rasi ~/.config/rofi/theme.rasi

hyprctl dispatch exec "swaybg -m fill -i /home/igor/Pictures/wallpapers/gradient_dark.avif"
hyprctl dispatch exec "swaybg -i /home/igor/Pictures/wallpapers/mask_vertical_4k.png"
sleep 1
while [ "$(pgrep -c swaybg)" -gt 2 ]; do pkill -o swaybg; done
