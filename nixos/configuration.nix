{ config, pkgs, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      inputs.home-manager.nixosModules.home-manager
      inputs.nixvim.nixosModules.nixvim
    ];

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      igor = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [

    biome
    go-tools
    gofumpt
    golangci-lint
    nixpkgs-fmt
    nodePackages.fixjson
    prettierd
    rustywind
    shfmt
    stylua
    taplo

    nodePackages.jsonlint

    _7zz
    adw-gtk3
    age
    android-file-transfer
    android-tools
    appflowy
    arduino-cli
    aria
    atool
    bat
    bc
    beekeeper-studio
    blender-hip
    brave
    bun
    chafa
    clang
    clinfo
    cliphist
    cmake
    corectrl
    dash
    ddcutil
    deno
    direnv
    dua
    dune3d
    exhibit
    exiftool
    eza
    fastfetch
    fd
    ffmpeg
    ffmpegthumbnailer
    file-roller
    flutter
    fnm
    font-manager
    fx
    fzf
    gimp
    gitleaks
    glow
    gnome-calculator
    gnome-disk-utility
    gnome-keyring
    gnumake
    go
    gparted
    gradience
    grim
    gum
    hyperfine
    hyprcursor
    hypridle
    hyprpicker
    imagemagick
    inkscape
    jamesdsp
    jdk
    jq
    kicad-small
    krita
    lazydocker
    lazygit
    lazysql
    libheif
    libqalculate
    libreoffice-fresh
    libsForQt5.kimageformats
    libsForQt5.qt5.qtwayland
    libsForQt5.qt5ct
    libsForQt5.qtstyleplugin-kvantum
    libva-utils
    lm_sensors
    localsend
    logiops
    losslesscut-bin
    man
    moar
    mods
    mpv
    mtpfs
    mumble
    nekoray
    nemo
    nemo-fileroller
    networkmanagerapplet
    nfs-utils
    ninja
    nodePackages.pnpm
    nodejs
    nvtopPackages.amd
    nwg-look
    obs-studio
    obsidian
    ocrmypdf
    openai-whisper-cpp
    openscad-unstable
    orca-slicer
    parallel
    pavucontrol
    pipx
    playerctl
    podman-tui
    polkit_gnome
    poppler_utils
    postgresql
    procs
    progress
    pulsemixer
    python3
    qemu
    qgnomeplatform
    qgnomeplatform-qt6
    qmk
    qrencode
    qt6.qtimageformats
    qt6.qtwayland
    qt6Packages.qt6ct
    qt6Packages.qtstyleplugin-kvantum
    quickemu
    qview
    ripgrep
    rustdesk-flutter
    sd
    shell-gpt
    signal-desktop
    slurp
    socat
    soft-serve
    solaar
    solvespace
    speedtest-go
    spotify
    stow
    sunshine
    swaybg
    swayosd
    telegram-desktop
    tlrc
    transmission_4-gtk
    unzip
    upscayl
    upx
    ventoy
    vial
    vulkan-tools
    wails
    wget
    wireguard-tools
    wl-clipboard
    wl-screenrec
    wtype
    xdg-utils
    xdragon
    xorg.xhost
    yarn
    yt-dlp
    zed-editor
    zip
    zoxide

  ];

  programs = {
    nh = {
      enable = true;
      flake = "/home/igor/dotfiles/nixos";
    };

    hyprland.enable = true;

    nixvim = {
      enable = true;

      colorschemes = {
        dracula = {
          enable = true;
          package = pkgs.vimPlugins.dracula-nvim;
        };
      };

      globals.mapleader = " ";

      opts = {
        breakindent = true;
        clipboard = "unnamedplus";
        completeopt = "menu,menuone,noinsert";
        expandtab = true;
        hlsearch = false;
        ignorecase = true;
        inccommand = "split";
        mouse = "a";
        number = true;
        pumheight = 10;
        relativenumber = true;
        scrolloff = 15;
        shiftwidth = 4;
        # showmode = false;
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

      highlight = {
        YankHighlight = {
          fg = "black";
          bg = "white";
        };
      };

      plugins = {

        auto-session.enable = true;
        cmp-buffer.enable = true;
        cmp-cmdline.enable = true;
        cmp-nvim-lsp.enable = true;
        cmp-path.enable = true;
        cmp_luasnip.enable = true;
        codeium-vim.enable = true;
        friendly-snippets.enable = true;
        indent-o-matic.enable = true;
        lspkind.enable = true;
        luasnip.enable = true;
        nvim-colorizer.enable = true;
        oil.enable = true;
        rainbow-delimiters.enable = true;
        web-devicons.enable = true;

        fidget = {
          enable = true;
          notification.window = {
            winblend = 0;
            border = "rounded";
          };
        };

        telescope = {
          enable = true;
          settings = {
            pickers = {
              find_files = {
                theme = "dropdown";
                previewer = false;
              };
              git_files = {
                theme = "dropdown";
                previewer = false;
              };
            };
          };
        };

        harpoon = {
          enable = true;
          keymaps = {
            addFile = "<leader>a";
            toggleQuickMenu = "<leader>b";
            navFile = {
              "1" = "<leader>j";
              "2" = "<leader>k";
              "3" = "<leader>l";
              "4" = "<leader>h";
            };
            navPrev = "H";
            navNext = "L";
          };
        };

        comment = {
          enable = true;
          settings = {
            toggler = { line = "<C-/>"; };
            pre_hook = "require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()";
          };
        };

        ts-context-commentstring = {
          enable = true;
          languages = {
            templ = {
              __default = "// %s";
              component_declaration = "<!-- %s -->";
            };
          };
        };

        gitsigns = {
          enable = true;
          settings = {
            signs = {
              add = { text = "+"; };
              change = { text = "~"; };
              delete = { text = "-"; };
              topdelete = { text = "‾"; };
              changedelete = { text = "~"; };
            };
          };
        };

        indent-blankline = {
          enable = true;
          settings = {
            indent.char = "│";
            scope.enabled = false;
          };
        };

        mini = {
          enable = true;
          modules = {
            indentscope = {
              symbol = "│";
              draw = {
                delay = 0;
                animation = config.lib.nixvim.mkRaw ''
                  function() return 0 end
                '';
              };
              options.border = "top";
            };
          };
        };

        conform-nvim = {
          enable = true;
          settings = {
            format_on_save = {
              lsp_format = "fallback";
            };
            formatters_by_ft = {
              astro = [ "prettierd" "rustywind" ];
              dart = [ "dart_format" ];
              go = [ "gofumpt" ];
              ino = [ "clang-format" ];
              javascript = [ "biome" ];
              json = [ "fixjson" "biome" ];
              lua = [ "stylua" ];
              markdown = [ "prettierd" ];
              nix = [ "nixpkgs_fmt" ];
              python = [ "ruff_format" "ruff_organize_imports" ];
              sh = [ "shfmt" ];
              svelte = [ "prettierd" "rustywind" ];
              templ = [ "templ" "rustywind" ];
              toml = [ "taplo" ];
              yaml = [ "prettierd" ];
            };
          };
        };

        lint = {
          enable = true;
          lintersByFt = {
            go = [ "golangcilint" ];
            json = [ "jsonlint" ];
          };
        };

        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            incremental_selection.enable = true;
            indent.enable = true;
            auto_install = true;
          };
        };

        cmp = {
          enable = true;

          settings = {
            completion.completeopt = "menu,menuone,noinsert";

            snippet.expand = ''
              function(args)
                  require('luasnip').lsp_expand(args.body)
              end
            '';

            sources = [
              { name = "nvim_lsp"; }
              { name = "path"; }
              { name = "luasnip"; }
              { name = "cmdline"; }
              { name = "buffer"; }
            ];

            mapping = {
              "<C-Space>" = "cmp.mapping.complete()";
              "<C-n>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
              "<C-p>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
              "<C-y>" = "cmp.mapping.confirm({ select = true })";
            };

            window = {
              completion.border = "rounded";
              documentation.border = "rounded";
            };
          };
        };

        lsp = {
          enable = true;
          servers = {
            astro.enable = true;
            bashls.enable = true;
            clangd = {
              enable = true;
              filetypes = [ "c" "cpp" "arduino" "h" "hpp" "cc" "hh" "cxx" "hxx" ];
            };
            gopls.enable = true;
            html.enable = true;
            htmx.enable = true;
            lua-ls.enable = true;
            marksman.enable = true;
            nil-ls.enable = true;
            pyright.enable = true;
            ruff.enable = true;
            rust-analyzer = {
              enable = true;
              installCargo = true;
              installRustc = true;
            };
            svelte.enable = true;
            tailwindcss.enable = true;
            templ.enable = true;
            ts-ls.enable = true;
          };

          keymaps = {
            diagnostic = {
              "<leader>pd" = "goto_prev";
              "<leader>nd" = "goto_next";
              "<leader>e" = "open_float";
            };
            lspBuf = {
              K = "hover";
            };
          };
        };

      };

      extraPlugins = with pkgs.vimPlugins; [
        nvim-web-devicons
      ];

      extraConfigLuaPre = ''
        require("dracula").setup({
            colors = {
                -- black = "#FFFFFF",
                -- bg = "#1A1A1A",
                -- menu = "#1A1A1A",
                black = "None",
                bg = "None",
                menu = "None",
            },
            italic_comment = true,
            transparent_bg = true,
        })

        local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
        vim.api.nvim_create_autocmd("TextYankPost", {
            callback = function()
                vim.highlight.on_yank({ higroup = "YankHighlight" })
            end,
            group = highlight_group,
            pattern = "*",
        })

        vim.filetype.add({ extension = { templ = "templ" } })
        vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
        vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
        vim.diagnostic.config({ float = { border = "rounded" } })
      '';

      keymaps = [
        { key = ";"; action = ":"; }

        { mode = "n"; key = "<C-s>"; action = ":w<CR>"; }
        { mode = [ "i" "v" ]; key = "<C-s>"; action = "<Esc>:w<CR>"; }

        { mode = [ "n" "i" ]; key = "<MiddleMouse>"; action = "<Nop>"; }
        { mode = [ "n" "i" "v" ]; key = "<RightMouse>"; action = "<Nop>"; }
        { mode = [ "n" "i" "v" ]; key = "<S-RightMouse>"; action = "<Nop>"; }

        { mode = "n"; key = "<C-h>"; action = "<C-w><C-h>"; }
        { mode = "n"; key = "<C-j>"; action = "<C-w><C-j>"; }
        { mode = "n"; key = "<C-k>"; action = "<C-w><C-k>"; }
        { mode = "n"; key = "<C-l>"; action = "<C-w><C-l>"; }

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

        { mode = "v"; key = "J"; action = ":m '>+1<CR>gv=gv"; options.silent = true; }
        { mode = "v"; key = "K"; action = ":m '<-2<CR>gv=gv"; options.silent = true; }

        { mode = "n"; key = "<leader>x"; action = ":bd<CR>"; }

        { mode = "n"; key = "<leader>rn"; action = ":IncRename "; }

        { mode = "n"; key = "<leader>f"; action.__raw = "require('telescope.builtin').find_files"; lua = true; }
        { mode = "n"; key = "<leader>g"; action.__raw = "require('telescope.builtin').git_files"; lua = true; }
        { mode = "n"; key = "<leader>w"; action.__raw = "require('telescope.builtin').live_grep"; lua = true; }
        { mode = "n"; key = "<leader>h"; action.__raw = "require('telescope.builtin').help_tags"; lua = true; }
        { mode = "n"; key = "<leader>d"; action.__raw = "require('telescope.builtin').diagnostics"; lua = true; }

        { mode = "n"; key = "gd"; action.__raw = "require('telescope.builtin').lsp_definitions"; lua = true; }
        { mode = "n"; key = "gr"; action.__raw = "require('telescope.builtin').lsp_references"; lua = true; }
        { mode = "n"; key = "gI"; action.__raw = "require('telescope.builtin').lsp_implementations"; lua = true; }

        # Increase and decrease ints
        { mode = "n"; key = "<C-S-a>"; action = "<C-a>"; }
        { mode = "n"; key = "<C-S-x>"; action = "<C-x>"; }

      ];
    };

    yazi = {
      enable = true;
      settings.yazi = {
        manager = {
          ratio = [ 0 2 3 ];
          sort_by = "extension";
          sort_dir_first = true;
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

    steam = {
      enable = false;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    gamemode.enable = false;

    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };

    dconf.enable = true;

    nix-ld.enable = true;
  };

  hardware = {
    bluetooth.enable = true;
    brillo.enable = true;
    i2c.enable = true;

    graphics.extraPackages = with pkgs; [
      rocmPackages.clr.icd
    ];
  };

  services = {
    blueman.enable = true;
    gvfs.enable = true;
    openssh.enable = true;
    udisks2.enable = true;

    resolved = {
      enable = true;
      extraConfig = ''
        [Resolve]
        DNS=45.90.28.0#nixos-7dd828.dns.nextdns.io
        DNS=2a07:a8c0::#nixos-7dd828.dns.nextdns.io
        DNS=45.90.30.0#nixos-7dd828.dns.nextdns.io
        DNS=2a07:a8c1::#nixos-7dd828.dns.nextdns.io
        DNSOverTLS=yes
      '';
    };

    syncthing = {
      enable = true;
      user = "igor";
      dataDir = "/home/igor/Sync";
      configDir = "/home/igor/.config/syncthing";
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # wireplumber.extraConfig."51-disable-suspend" = ''
      #   alsa_monitor.rules = {
      #       {
      #           matches = {
      #               {
      #                   -- Matches all sources.
      #                   { "node.name", "matches", "alsa_input.*" },
      #               },
      #               {
      #                   -- Matches all sinks.
      #                   { "node.name", "matches", "alsa_output.*" },
      #               },
      #           },
      #           apply_properties = {
      #               ["session.suspend-timeout-seconds"] = 0,
      #           },
      #       },
      #   }
      # '';
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
    initrd.kernelModules = [ "amdgpu" ];
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    extraModulePackages = with config.boot.kernelPackages; [ apfs ddcci-driver ];
    kernelModules = [ "ddcci_backlight" ];
    # kernelPackages = pkgs.linuxPackages_latest;
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
      extraGroups = [ "networkmanager" "wheel" "video" "i2c" "kvm" "uucp" "dialout" ];
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
      rubik
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
        sansSerif = [ "Inter" ];
        serif = [ "Inter" ];
        monospace = [ "Iosevka" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };

  system.stateVersion = "23.11";

  nix = {
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  environment = {
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
  };
}
