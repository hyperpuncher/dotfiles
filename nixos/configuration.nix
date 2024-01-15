# man configuration.nix(5)
# nixos-help

{ config, pkgs, inputs, outputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.nixvim.nixosModules.nixvim
    ];

  home-manager = {
    extraSpecialArgs = { inherit inputs outputs; };
    users = {
      igor = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    # android-file-transfer
    # android-tools
    # bun
    # corectrl
    # davinci-resolve
    # ffmpeg
    # font-manager
    # gimp
    # git-leaks
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
    localsend
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

    nixvim = {
      enable = true;

      colorscheme = "dracula";

      globals.mapleader = " ";

      options = {
        breakindent = true;
        clipboard = "unnamedplus";
        completeopt = "menuone,noselect";
        expandtab = true;
        hlsearch = false;
        ignorecase = true;
        mouse = "a";
        number = true;
        pumheight = 10;
        relativenumber = true;
        scrolloff = 15;
        shiftwidth = 4;
        showmode = false;
        signcolumn = "yes";
        smartcase = true;
        smartindent = true;
        softtabstop = 4;
        spell = false;
        splitright = true;
        swapfile = false;
        tabstop = 4;
        termguicolors = true;
        timeoutlen = 500;
        undofile = true;
        updatetime = 200;
      };

      plugins = {
        comment-nvim = {
          enable = true;
          toggler = {
            line = "<C-/>";
          };
        };

        gitsigns = {
          enable = true;
          signs = {
            add = { text = "+"; };
            change = { text = "~"; };
            delete = { text = "_"; };
            topdelete = { text = "‾"; };
            changedelete = { text = "~"; };
          };
        };

        indent-blankline = {
          enable = true;
          indent = {
            char = "│";
          };
          scope = {
            showStart = false;
          };
        };

        lsp-format.enable = true;

        lualine = {
          enable = true;
          globalstatus = true;
          componentSeparators = {
            left = "";
            right = "";
          };
          sectionSeparators = {
            left = "";
            right = "";
          };
          sections = {
            lualine_a = [ "mode" ];
            lualine_b = [ "" ];
            # lualine_c = [ "" ];
            lualine_x = [ "" ];
            lualine_y = [ "" ];
            lualine_z = [ "location" ];
          };
        };

        luasnip.enable = true;
        nvim-cmp.enable = true;
        oil.enable = true;
        telescope.enable = true;

        treesitter = {
          enable = true;
          indent = true;
        };

        rainbow-delimiters.enable = false;

        lsp = {
          enable = true;
          servers = {
            rnix-lsp.enable = true;
          };
        };

        none-ls = {
          enable = true;
          sources = {
            formatting = {
              nixpkgs_fmt.enable = true;
              prettier.enable = true;
              shfmt.enable = true;
              stylua.enable = true;
            };

            diagnostics = {
              deadnix.enable = true;
              golangci_lint.enable = true;
              shellcheck.enable = true;
              staticcheck.enable = true;
              statix.enable = true;
            };
          };
        };

      };

      extraPlugins = with pkgs.vimPlugins; [
        dracula-nvim
      ];

      extraConfigLuaPre = ''
        require("dracula").setup({
            colors = {
                bg = "#1A1A1A",
                menu = "#1A1A1A",
            },
            italic_comment = true,
        })
    
        vim.api.nvim_set_hl(0, "YankHighlight", { fg = "black", bg = "white" })
        local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
        vim.api.nvim_create_autocmd("TextYankPost", {
            callback = function()
                vim.highlight.on_yank({ higroup = "YankHighlight" })
            end,
            group = highlight_group,
            pattern = "*",
        })
      '';

      keymaps = [
        {
          mode = "n";
          key = "<C-s>";
          action = ":w<CR>";
        }
        {
          mode = [ "i" "v" ];
          key = "<C-s>";
          action = "<Esc>:w<CR>";
        }
      ];
    };

    yazi = {
      enable = true;
      settings.yazi = {
        manager = {
          layout = [ 0 2 3 ];
          sort_by = "natural";
          sort_sensitive = false;
          sort_reverse = false;
          show_hidden = true;
        };

        preview = {
          max_width = 2000;
          max_height = 2000;
        };
      };
    };

    firefox.enable = true;

    steam = {
      enable = false;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamemode.enable = true;

    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    dconf.enable = true;
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

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
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
