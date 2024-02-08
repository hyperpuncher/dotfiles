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
    # davinci-resolve
    adw-gtk3
    age
    alacritty
    android-file-transfer
    android-tools
    aria
    atool
    bat
    bun
    chafa
    clang
    cliphist
    corectrl
    dash
    ddcutil
    dua
    eza
    fd
    ffmpeg
    ffmpegthumbnailer
    fnm
    font-manager
    fx
    fzf
    gimp
    gitleaks
    glow
    gnome.file-roller
    gnome.gnome-disk-utility
    gnome.gnome-keyring
    gparted
    gradience
    grim
    gum
    hyprpicker
    imagemagick
    inkscape
    jamesdsp
    jq
    kicad-small
    lazydocker
    lazygit
    libreoffice-fresh
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    libva-utils
    lm_sensors
    localsend
    logiops
    losslesscut-bin
    man
    moar
    mpv
    mtpfs
    mumble
    nasc
    networkmanagerapplet
    nfs-utils
    nodePackages.pnpm
    nodejs
    nvtop
    nwg-look
    obs-studio
    ocrmypdf
    parallel
    pavucontrol
    pfetch-rs
    playerctl
    polkit_gnome
    procs
    pulsemixer
    qemu
    qgnomeplatform
    qgnomeplatform-qt6
    qrencode
    qt6.qtimageformats
    qt6.qtwayland
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
    quickemu
    qview
    ripgrep
    rofi-calc
    rustdesk
    shell_gpt
    slurp
    soft-serve
    solaar
    solvespace
    speedtest-go
    spotify
    stow
    sunshine
    swaybg
    telegram-desktop
    tlrc
    transmission_4
    ungoogled-chromium
    unzip
    upscayl
    ventoy
    vial
    vulkan-tools
    wget
    wireguard-tools
    wl-clipboard
    wl-screenrec
    wtype
    xdragon
    xorg.xhost
    yarn
    yt-dlp
    zip
    zoxide
  ];

  programs = {
    hyprland.enable = true;

    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-archive-plugin
        thunar-volman
      ];
    };

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
            lualine_c = [ "buffers" ];
            lualine_x = [ "" ];
            lualine_y = [ "" ];
            lualine_z = [ "location" ];
          };
        };

        luasnip.enable = true;
        nvim-cmp.enable = true;
        oil.enable = true;
        telescope.enable = true;
        auto-session.enable = true;
        rainbow-delimiters.enable = true;

        treesitter = {
          enable = true;
          indent = true;
        };

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
              gofumpt.enable = true;
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
        { key = ";"; action = ":"; }

        { mode = "n"; key = "<C-s>"; action = ":w<CR>"; }
        { mode = [ "i" "v" ]; key = "<C-s>"; action = "<Esc>:w<CR>"; }

        { mode = [ "n" "i" ]; key = "<MiddleMouse>"; action = "<Nop>"; }
        { mode = [ "n" "i" "v" ]; key = "<RightMouse>"; action = "<Nop>"; }
        { mode = [ "n" "i" "v" ]; key = "<S-RightMouse>"; action = "<Nop>"; }

        { mode = "n"; key = "<C-d>"; action = "0<C-d>zz"; }
        { mode = "n"; key = "<C-u>"; action = "0<C-u>zz"; }
        { mode = "n"; key = "G"; action = "0Gzz"; }
        { mode = "n"; key = "N"; action = "Nzz"; }
        { mode = "n"; key = "n"; action = "nzz"; }
        { mode = [ "n" "v" ]; key = "<Space>"; action = "<Nop>"; }
        { mode = "n"; key = "<C-a>"; action = "ggVG"; }
        { mode = [ "i" "c" ]; key = "<C-v>"; action = "<C-R><C-R>+"; }

        { mode = "n"; key = "k"; action = "v:count == 0 ? 'gk' : 'k'"; options.silent = true; options.expr = true; }
        { mode = "n"; key = "j"; action = "v:count == 0 ? 'gj' : 'j'"; options.silent = true; options.expr = true; }

        { mode = "n"; key = "-"; action = "<CMD>Oil<CR>"; }

        { mode = "n"; key = "<leader>u"; action = ":UndotreeShow<CR><C-w>h"; options.silent = true; }

        { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.silent = true; }
        { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.silent = true; }

        { mode = "n"; key = "<leader>l"; action = ":Lazy<CR>"; options.silent = true; }

        { mode = "n"; key = "<S-l>"; action = ":bnext<CR>"; options.silent = true; }
        { mode = "n"; key = "<S-h>"; action = ":bprevious<CR>"; options.silent = true; }
        { mode = "n"; key = "<leader>x"; action = ":bd<CR>"; }

        { mode = "n"; key = "<leader>rn"; action = ":IncRename "; }

        { mode = "n"; key = "<leader>f"; action = "require('telescope.builtin').find_files"; lua = true; }
        { mode = "n"; key = "<leader>g"; action = "require('telescope.builtin').git_files"; lua = true; }
        { mode = "n"; key = "<leader>w"; action = "require('telescope.builtin').live_grep"; lua = true; }
        { mode = "n"; key = "<leader>r"; action = "require('telescope.builtin').oldfiles"; lua = true; }
        { mode = "n"; key = "<leader>b"; action = "require('telescope.builtin').buffers"; lua = true; }
        { mode = "n"; key = "<leader>h"; action = "require('telescope.builtin').help_tags"; lua = true; }
        { mode = "n"; key = "<leader>d"; action = "require('telescope.builtin').diagnostics"; lua = true; }

      ];
    };

    yazi = {
      enable = true;
      settings.yazi = {
        manager = {
          ratio = [ 0 2 3 ];
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
    brillo.enable = true;
    i2c.enable = true;

    opengl.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services = {
    blueman.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    udisks2.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Configure keymap in X11
    xserver.xkb = {
      layout = "us";
      variant = "";
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

    udev.packages = with pkgs; [ via ];
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    kernelModules = [ "ddcci_backlight" ];
    kernelPackages = pkgs.linuxPackages_latest;
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

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };
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
      corefonts
      inter
      iosevka
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      ubuntu_font_family

      (nerdfonts.override {
        fonts = [
          "CascadiaCode"
          "IosevkaTerm"
        ];
      })
    ];

    fontconfig = {
      hinting.enable = false;
      subpixel.rgba = "rgb";
      defaultFonts = {
        sansSerif = [ "Inter Display" ];
        serif = [ "Inter Display" ];
        monospace = [ "Iosevka" ];
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
      NIXOS_OZONE_WL = "1";
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
