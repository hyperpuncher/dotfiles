{ pkgs, ... }:

{
  # imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [
    aria
    chafa
    atool
    bat
    btop
    clang
    dua
    eza
    fd
    fzf
    jq
    man
    moar
    podman-tui
    procs
    qrencode
    ripgrep
    speedtest-go
    stow
    tlrc
    unzip
    _7zz
    wget
    wireguard-tools
    zip
    zoxide
  ];

  systemd.tmpfiles.rules = [
    "d /root/containers 0770 root root -"
    "d /root/downloads 0770 root root -"
  ];

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
    };

    oci-containers.containers = {

      qbittorrent = {
        image = "lscr.io/linuxserver/qbittorrent:latest";
        # user = "1000:1000";

        environment = {
          TZ = "Europe/Minsk";
          WEBUI_PORT = "8080";
        };

        volumes = [
          "/root/containers:/config"
          "/root/downloads:/downloads"
        ];

        ports = [
          "8080:8080"
          "6881:6881"
          "6881:6881/udp"
        ];
      };
    };
  };

  programs = {
    git.enable = true;

    neovim.enable = true;

    yazi = {
      enable = true;
      settings.yazi = {
        manager = {
          ratio = [ 0 2 3 ];
          sort_by = "natural";
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

    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
  };

  services = {
    openssh.enable = true;
    cockpit.enable = true;
    qemuGuest.enable = true;
  };

  networking = {
    hostName = "nixos-server";

    # Open ports in the firewall.
    # firewall.allowedTCPPorts = [ ... ];
    # firewall.allowedUDPPorts = [ ... ];
    # Or disable the firewall altogether.
    firewall.enable = false;
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

    users.root.password = "nixos";

    # users.igor = {
    #   isNormalUser = true;
    #   description = "igor";
    #   password = "asdf";
    #   extraGroups = [ "networkmanager" "wheel" "podman" ];
    #   home = "/home/igor";
    #   createHome = true;
    # };
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  system.stateVersion = "24.05";

  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

}
