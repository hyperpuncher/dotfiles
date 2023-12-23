# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, outputs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      # Import your home-manager configuration
      igor = import ./home.nix;
    };
  };

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
      # davinci-resolve
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

  environment.variables = {
    BAT_THEME = "Dracula";
    BROWSER = "firefox";
    EDITOR = "nvim";
    HISTORY_IGNORE = "(ls|la|cd|cd ..|cd -|cd -|z|z ..|z -|lg|d)";
    MANPAGER = "nvim + Man!";
    PAGER = "moar - style dracula - no-linenumbers";
    PF_INFO = "ascii title os de kernel pkgs memory";
    TERM = "xterm-kitty";
    VISUAL = "nvim";

    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };

  #ZSH
  users.defaultUserShell = pkgs.zsh;
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;

    shellAliases = {
      bt = "bluetoothctl";
      "c." = "codium . >/dev/null 2>&1";
      c = "codium >/dev/null 2>&1";
      cat = "bat -pp";
      d = "cd ~/dotfiles/";
      dev = "pnpm run dev --host";
      fd = "fd -HI -E Desktop";
      fzf = "fzf --preview 'bat - -color=always {}' --preview-window=right:60%:wrap";
      gc = "git clone";
      gp = "git pull";
      lg = "lazygit";
      ll = "eza -a --icons --group-directories-first -s ext --long";
      ls = "eza -a --icons --group-directories-first -s ext";
      lsblk = "lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINT,FSUSE% | rg -v SWAP";
      lt = "eza -T -L=2 -a --icons --group-directories-first";
      mkdir = "mkdir -p";
      n = "cd ~/projects/newtonlabs";
      p = "cd ~/projects";
      pipreqs = "pipreqs --force && sort -u requirements.txt -o requirements.txt";
      rg = "rg --hidden --no-ignore --no-messages";
      rmf = "rm -rf";
      ssh_butterbot = "ssh root@192.168.31.75";
      ssh_deb_server = "ssh igor@192.168.31.104";
      ssh_printer = "ssh igor@192.168.31.94";
      ssh_racknerd = "ssh user@172.245.180.243";
      stow = "stow --no-folding -Rv";
      sv = "sudoedit";
      udiskmount = "udisksctl mount -b";
      v = "nvim";
      wgdown = "basename /proc/sys/net/ipv4/conf/*vpn | xargs sudo wg-quick down";
      wgup = "sudo wg-quick up";
    };

    setOptions = [
      "HIST_IGNORE_ALL_DUPS"
      "AUTO_CD"
      "EMACS"
    ];

    shellInit = "pfetch";

    syntaxHighlighting = {
      enable = true;
      styles = {
        "alias" = "fg=#50FA7B";
        "arg0" = "fg=#F8F8F2";
        "assign" = "fg=#F8F8F2";
        "autodirectory" = "fg=#FFB86C,italic";
        "back-dollar-quoted-argument" = "fg=#FF79C6";
        "back-double-quoted-argument" = "fg=#FF79C6";
        "back-quoted-argument-delimiter" = "fg=#FF79C6";
        "back-quoted-argument-unclosed" = "fg=#FF5555";
        "back-quoted-argument" = "fg=#BD93F9";
        "builtin" = "fg=#8BE9FD";
        "command-substitution-delimiter-quoted" = "fg=#F1FA8C";
        "command-substitution-delimiter-unquoted" = "fg=#F8F8F2";
        "command-substitution-delimiter" = "fg=#F8F8F2";
        "command-substitution-quoted" = "fg=#F1FA8C";
        "command" = "fg=#50FA7B";
        "commandseparator" = "fg=#FF79C6";
        "comment" = "fg=#6272A4";
        "cursor" = "standout";
        "default" = "fg=#F8F8F2";
        "dollar-double-quoted-argument" = "fg=#F8F8F2";
        "dollar-quoted-argument-unclosed" = "fg=#FF5555";
        "dollar-quoted-argument" = "fg=#F8F8F2";
        "double-hyphen-option" = "fg=#FFB86C";
        "double-quoted-argument-unclosed" = "fg=#FF5555";
        "double-quoted-argument" = "fg=#F1FA8C";
        "function" = "fg=#50FA7B";
        "global-alias" = "fg=#50FA7B";
        "globbing" = "fg=#F8F8F2";
        "hashed-command" = "fg=#8BE9FD";
        "history-expansion" = "fg=#BD93F9";
        "named-fd" = "fg=#F8F8F2";
        "numeric-fd" = "fg=#F8F8F2";
        "path" = "fg=#F8F8F2";
        "path_pathseparator" = "fg=#FF79C6";
        "path_prefix" = "fg=#F8F8F2";
        "path_prefix_pathseparator" = "fg=#FF79C6";
        "precommand" = "fg=#50FA7B,italic";
        "process-substitution-delimiter" = "fg=#F8F8F2";
        "rc-quote" = "fg=#F1FA8C";
        "redirection" = "fg=#F8F8F2";
        "reserved-word" = "fg=#8BE9FD";
        "single-hyphen-option" = "fg=#FFB86C";
        "single-quoted-argument-unclosed" = "fg=#FF5555";
        "single-quoted-argument" = "fg=#F1FA8C";
        "suffix-alias" = "fg=#50FA7B";
        "unknown-token" = "fg=#FF5555";
      };
    };

  };


}
