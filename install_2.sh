#!/bin/bash

sudo dnf upgrade -y &&

sudo dnf install --allowerasing -y i3-gaps kitty code arandr feh unzip lxpolkit rofi picom nnn lxappearance easyeffects xprop neofetch polybar telegram zsh playerctl ddccontrol ddccontrol-gtk zsh-autosuggestions zsh-syntax-highlighting redshift xclip xdotool materia-gtk-theme papirus-icon-theme exa mpv qbittorrent android-file-transfer telegram-desktop speedcrunch btop &&

cd dotfiles &&

stow -t --no-folding /home/igor/ */ &&

echo  -e "\e[1;36mPoopity poop may I offer reboop"
