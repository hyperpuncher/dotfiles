environment.systemPackages = with pkgs; [
    kitty
    rofi-wayland
android-file-transfer
android-tools
aria
bat
bibata-cursors
btop
bun
cliphist
corectrl
dash
ddcutil
xdragon
dunst
eza
fd
ffmpeg
gnome.file-roller
firefox
fnm
font-manager
fx
fzf
]

fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk   
    noto-fonts-emoji
    
    (nerdfonts.override { fonts = [
        "CascadiaCode"
        "JetBrainsMono"
        "UbuntuMono"
    ]; })
]

hardware.bluetooth.enable = true;
hardware.bluetooth.powerOnBoot = true;
services.blueman.enable = true;

virtualisation.docker.enable = true;
users.users.igor.extraGroups = [ "docker" ];
virtualisation.docker.rootless = {
  enable = true;
  setSocketVariable = true;
};

boot.extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];



gdu
gimp
glow
gnome.gnome-disk-utility
gnome.gnome-keyring
gparted
grim
gvfs
hyprpicker
imagemagick
inkscape
jamesdsp
jq
qt6Packages.qtstyleplugin-kvantum

lazydocker
lazygit
lf
libreoffice-fresh
linux-headers
losslesscut-bin
man-db
moar
mpv
mtpfs
mumble
nasc
ncspot-bin
network-manager-applet
nfs-utils
npm
nvtop
nwg-look
obs-studio
obsidian
ocrmypdf
orca-slicer-bin
papirus-folders-git
papirus-icon-theme
parallel
pavucontrol
pfetch-rs-bin
pnpm
polkit-gnome
procs
pulsemixer
python-beautifulsoup4
python-dotenv
python-numpy
python-pillow
python-pip
python-pipreqs
python-pipx
python-pynvim
python-pytelegrambotapi
python-requests
python-rich
python-setuptools
python-tabulate
python-wxpython
qemu-full
qrencode
qt5-imageformats
qt5-wayland
qt5ct
qt6-wayland
qt6ct
quickemu
qview
ripgrep
rofi-calc
rofi-emoji
rofi-rbw
rustdesk-bin
shell-gpt
signal-desktop
slurp
solaar
solvespace
speedtest-go
spotify-edge
sunshine
swaybg
telegram-desktop
thunar
thunar-archive-plugin
thunar-volman
tldr
transmission-gtk
udiskie
ungoogled-chromium-bin
unzip
upscayl-bin
ventoy-bin
vial-appimage
vscodium-bin
waybar
wget
wireguard-tools
wl-clipboard
wl-screenrec
wtype
xdg-desktop-portal-hyprland
xdg-ninja
xorg-xhost
yarn
yt-dlp
zip
zoxide
zsh-autosuggestions
zsh-history-substring-search
zsh-syntax-highlighting
zsh-theme-powerlevel10k-git


greetd.tuigreet


brillo
ddcci-driver-linux-dkms
gammastep

dirstat-rs-git