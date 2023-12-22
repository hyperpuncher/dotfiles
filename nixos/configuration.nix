programs.hyprland.enable = true

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --window-padding 2 --asterisks --remember --remember-session --time --width 50 --cmd Hyprland";
        user = "greeter";
      };
    };
  };

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
    losslesscut-bin
    man
    moar
    mpv
    mtpfs
    mumble
    nasc
    networkmanagerapplet
    nfs-utils
    nodejs
    nvtop
    nwg-look
    obs-studio
    obsidian
    ocrmypdf
    papirus-folders
    papirus-icon-theme
    parallel
    pavucontrol
    pfetch-rs
    nodePackages.pnpm
    polkit_gnome
    procs
    pulsemixer
    qemu
    qrencode
    qt6.qtimageformats
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    qt6.qtwayland
    qt6Packages.qt6ct
    quickemu
    qview
    ripgrep
    rofi-calc
    rustdesk
    shell_gpt
    slurp
    solaar
    solvespace
    speedtest-go
    spotify
    sunshine
    swaybg
    telegram-desktop
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-volman
    tlrc
    transmission_4
    udiskie
    ungoogled-chromium
    unzip
    upscayl
    ventoy
    vial
    vscodium
    waybar
    wget
    wireguard-tools
    wl-clipboard
    wl-screenrec
    wtype
    xorg.xhost
    yarn
    yt-dlp
    zip
    zoxide
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