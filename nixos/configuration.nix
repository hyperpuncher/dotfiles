# man configuration.nix(5)
# nixos-help

{ config, pkgs, inputs, outputs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
    ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      igor = import ./home.nix;
    };
  };

  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # android-file-transfer
    # android-tools
    # bun
    # corectrl
    # davinci-resolve
    # ffmpeg
    # font-manager
    # gimp
    # inkscape
    # libreoffice-fresh
    # mumble
    # obs-studio
    # obsidian
    # ocrmypdf
    # polkit_gnome
    # qemu
    # quickemu
    # rustdesk
    # shell_gpt
    # solvespace
    # spotify
    # sunshine
    # telegram-desktop
    # ungoogled-chromium
    # upscayl
    # ventoy
    # vial
    # yt-dlp
    aria
    atool
    bat
    chafa
    clang
    cliphist
    dash
    ddcutil
    eza
    fd
    ffmpegthumbnailer
    fnm
    fx
    fzf
    gdu
    glow
    gnome.file-roller
    gnome.gnome-disk-utility
    gnome.gnome-keyring
    gparted
    grim
    gvfs
    hyprpicker
    imagemagick
    jamesdsp
    jq
    lazydocker
    lazygit
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    losslesscut-bin
    man
    moar
    mpv
    mtpfs
    nasc
    networkmanagerapplet
    nfs-utils
    nodePackages.pnpm
    nodejs
    nvtop
    nwg-look
    parallel
    pavucontrol
    pfetch-rs
    playerctl
    procs
    pulsemixer
    qgnomeplatform
    qgnomeplatform-qt6
    qrencode
    qt6.qtimageformats
    qt6.qtwayland
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
    qview
    ripgrep
    rofi-calc
    slurp
    solaar
    speedtest-go
    stow
    swaybg
    tlrc
    transmission_4
    unzip
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
    zip
    zoxide
  ];

  programs = {
    hyprland.enable = true;

    neovim = {
      enable = true;
      defaultEditor = true;
    };

    yazi = {
      enable = true;
    };

    firefox.enable = true;

    zsh = {
      enable = true;
      autosuggestions.enable = true;

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

    # Some programs need SUID wrappers, can be configured further or are
    # started in user sessions.
    # mtr.enable = true;
    # gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
  };

  hardware = {
    bluetooth.enable = true;
    bluetooth.powerOnBoot = true;
    brillo.enable = true;
    i2c.enable = true;
  };

  services = {
    blueman.enable = true;
    openssh.enable = true;
    udisks2.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Configure keymap in X11
    xserver = {
      layout = "us";
      xkbVariant = "";
    };

    greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --window-padding 2 --asterisks --remember --remember-session --time --width 50 --cmd Hyprland";
          user = "greeter";
        };
      };
    };
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    kernelModules = [ "ddcci_backlight" ];
  };

  networking = {
    hostName = "nixos";

    networkmanager.enable = true;

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    # firewall.enable = false;
  };

  # Hands out realtime scheduling priority to user processes on demand
  security.rtkit.enable = true;

  sound.mediaKeys.enable = true;

  time.timeZone = "Europe/Minsk";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  users = {
    defaultUserShell = pkgs.zsh;

    users.igor = {
      isNormalUser = true;
      description = "igor";
      extraGroups = [ "networkmanager" "wheel" "video" "i2c" ];
      packages = with pkgs; [ ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  fonts = {
    packages = with pkgs; [
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

    fontconfig = {
      hinting.enable = false;
      subpixel.rgba = "rgb";
      defaultFonts = {
        sansSerif = [ "JetBrainsMono Nerd Font" ];
        serif = [ "JetBrainsMono Nerd Font" ];
        monospace = [ "JetBrainsMono Nerd Font" ];
      };
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  system.stateVersion = "23.11";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  environment = {
    sessionVariables = {
      BROWSER = "firefox";
      EDITOR = "nvim";
      NIXOS_OZONE_WL = "1";
      VISUAL = "nvim";

      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_STATE_HOME = "$HOME/.local/state";
    };

    variables = {
      BAT_THEME = "Dracula";
      HISTORY_IGNORE = "(ls|la|cd|cd ..|cd -|cd -|z|z ..|z -|lg|d)";
      MANPAGER = "nvim + Man!";
      PAGER = "moar -style dracula -no-linenumbers";
      PF_ASCII = "linux";
      PF_INFO = "ascii title os de kernel pkgs memory";
      TERM = "wezterm";
    };

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

    etc = {
      "wireplumber/main.lua.d/51-pc38x-rename.lua".text = ''
        rule = {
          matches = {
            {
              { "node.name", "equals", "alsa_output.usb-FiiO_FiiO_BTR3K_ABCDEF0123456789-00.analog-stereo" },
            }
          },
          apply_properties = {
            ["device.description"] = "Sennheiser PC38X",
            ["device.nick"] = "Sennheiser PC38X",
            ["node.description"] = "Sennheiser PC38X",
            ["node.nick"] = "Sennheiser PC38X",
          },
        }
        table.insert(alsa_monitor.rules, rule)
      '';

      "wireplumber/main.lua.d/51-mic-rename.lua".text = ''
        rule = {
          matches = {
            {
              { "node.name", "equals", "alsa_input.pci-0000_09_00.4.analog-stereo" },
            }
          },
          apply_properties = {
            ["node.description"] = "Mic",
            ["node.nick"] = "Mic",
          },
        }
        table.insert(alsa_monitor.rules, rule)
      '';

      "wireplumber/main.lua.d/51-alsa-disable.lua".text = ''
        rule = {
          matches = {
              -- display home
              {
                  { "device.name", "equals", "alsa_card.pci-0000_07_00.1" },
              },
              {
                  { "node.name", "equals", "alsa_output.pci-0000_09_00.4.iec958-stereo" },
              },
              -- display work
              {
                  { "device.name", "equals", "alsa_card.pci-0000_07_00.1.3" },
              },
              -- system card work
              {
                  { "device.name", "equals", "alsa_card.pci-0000_07_00.6" },
              }
          },
          apply_properties = {
              ["node.disabled"] = true,
              ["device.disabled"] = true,
          },
        }
        table.insert(alsa_monitor.rules, rule)
      '';

      "wireplumber/main.lua.d/51-system-card-rename.lua".text = ''
        rule = {
            matches = {
                {
                    { "device.name", "equals", "alsa_card.pci-0000_09_00.4" },
                },
                {
                    { "device.name", "equals", "alsa_card.pci-0000_07_00.6" },
                }

            },
            apply_properties = {
                ["device.description"] = "System Card",
                ["device.nick"] = "System Card",
            },
        }
        table.insert(alsa_monitor.rules, rule)
      '';
    };
  };
}
