#!/bin/bash

sudo dnf upgrade -y &&

dnf install --allowerasing -y i3-gaps kitty code arandr feh unzip lxpolkit rofi picom nnn lxappearance easyeffects xprop neofetch polybar telegram zsh playerctl ddccontrol ddccontrol-gtk zsh-autosuggestions zsh-syntax-highlighting redshift xclip xdotool materia-gtk-theme papirus-icon-theme exa mpv qbittorrent android-file-transfer &&

cd dotfiles &&

stow -t /home/igor/ */ &&

echo "Poopity poop may I offer reboop"

