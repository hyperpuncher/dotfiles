# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Minsk";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IE.UTF-8";
    LC_IDENTIFICATION = "en_IE.UTF-8";
    LC_MEASUREMENT = "en_IE.UTF-8";
    LC_MONETARY = "en_IE.UTF-8";
    LC_NAME = "en_IE.UTF-8";
    LC_NUMERIC = "en_IE.UTF-8";
    LC_PAPER = "en_IE.UTF-8";
    LC_TELEPHONE = "en_IE.UTF-8";
    LC_TIME = "en_IE.UTF-8";
  };

  # Configure keymap in X11
  # services.xserver = {
  # layout = "us";
  # xkbVariant = "";
  # };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.igor = {
    isNormalUser = true;
    description = "igor";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [ ];
  };

  # home-manager = {
  #   specialArgs = { inherit inputs; };
  #   users = { "igor" = import ./home.nix; };
  # };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.hyprland.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --window-padding 2 --asterisks --remember --remember-session --time --width 50 --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    (nerdfonts.override {
      fonts = [
        "CascadiaCode"
        "JetBrainsMono"
        "UbuntuMono"
      ];
    })
  ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # android-file-transfer
      # android-tools
      aria
      bat
      bibata-cursors
      btop
      # bun
      cliphist
      # corectrl
      dash
      ddcutil
      dunst
      eza
      fd
      # ffmpeg
      firefox
      fnm
      # font-manager
      fx
      fzf
      gdu
      # gimp
      git
      glow
      gnome.file-roller
      gnome.gnome-disk-utility
      gnome.gnome-keyring
      gparted
      grim
      gvfs
      hyprpicker
      imagemagick
      # inkscape
      jamesdsp
      jq
      kitty
      lazydocker
      lazygit
      lf
      # libreoffice-fresh
      libsForQt5.qt5.qtwayland
      libsForQt5.qt5ct
      losslesscut-bin
      man
      moar
      mpv
      mtpfs
      # mumble
      nasc
      networkmanagerapplet
      nfs-utils
      nodePackages.pnpm
      nodejs
      nvtop
      nwg-look
      # obs-studio
      # obsidian
      # ocrmypdf
      papirus-folders
      papirus-icon-theme
      parallel
      pavucontrol
      pfetch-rs
      polkit_gnome
      procs
      pulsemixer
      # qemu
      qrencode
      qt6.qtimageformats
      qt6.qtwayland
      qt6Packages.qt6ct
      qt6Packages.qtstyleplugin-kvantum
      # quickemu
      qview
      ripgrep
      rofi-calc
      rofi-wayland
      # rustdesk
      # shell_gpt
      slurp
      solaar
      # solvespace
      speedtest-go
      # spotify
      stow
      # sunshine
      swaybg
      # telegram-desktop
      tlrc
      transmission_4
      udiskie
      # ungoogled-chromium
      unzip
      # upscayl
      # ventoy
      # vial
      vscodium
      waybar
      wget
      wireguard-tools
      wl-clipboard
      wl-screenrec
      wtype
      xdragon
      xfce.thunar
      xfce.thunar-archive-plugin
      xfce.thunar-volman
      xorg.xhost
      yarn
      # yt-dlp
      zip
      zoxide
    ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
