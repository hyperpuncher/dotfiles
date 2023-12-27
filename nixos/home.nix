{ config, pkgs, ... }:

{
  home = {
    username = "igor";
    homeDirectory = "/home/igor";
    stateVersion = "23.11";
    packages = [ ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through 'home.file'.
    file = {
      # # Building this configuration will create a copy of 'dotfiles/screenrc' in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };

    sessionVariables = {
      # EDITOR = "emacs";
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      "$mod" = "SUPER";

      monitor = ",preferred,auto,auto";

      exec-once = [
        "waybar"
        "jamesdsp -t"
        "blueman-applet"
        "nm-applet"

        "wl-paste --type text --watch cliphist store" #Stores only text data
        "wl-paste --type image --watch cliphist store" #Stores only image data
        "wl-paste -p --watch wl-copy -pc" #Disable middle click paste
      ];

      windowrule = [
        "float, ^(blueman-manager)$"
        "float, ^(com\.github.parnold_x\.nasc)$"
        "float, ^(quickgui)$"
        "float, title:^(File Operation Progress)$"
        "tile, ^(qemu-system-x86_64)$"
        "workspace 3 silent, title:^(Telegram.*)$"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:rctrl_toggle";

        follow_mouse = 1;

        repeat_rate = 35;
        repeat_delay = 450;
      };

      bind = [
        "$mod, ESCAPE, exec, ~/.config/rofi/scripts/power_menu.sh"
        "$mod, RETURN, exec, kitty"
        "$mod, E, exec, thunar"
        "$mod, B, exec, firefox"
        "$mod, K, exec, hyprctl kill"
        "$mod, D, exec, rofi -show drun -display-drun 'Apps'"
        "$mod, Q, killactive,"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, F, fullscreen"
        "$mod SHIFT, F, togglefloating"

        ", XF86MonBrightnessDown, exec, brillo -q -U 5"
        ", XF86MonBrightnessUp, exec, brillo -q -A 5"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"
      ];

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        vrr = 1;
      };
    };
  };

  programs = {
    home-manager.enable = true;

    btop = {
      enable = true;
      settings = {
        color_theme = "dracula";
        shown_boxes = "cpu proc";
      };
    };

    git = {
      enable = true;
      userName = "hyperpuncher";
      userEmail = "39203616+hyperpuncher@users.noreply.github.com";
      extraConfig = {
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      };
    };

    kitty = {
      enable = true;
      font.name = "JetBrainsMono Nerd Font";
      font.size = 14;
      theme = "Monokai Soda";
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        window_margin_width = 5;
      };
      keybindings = {
        "ctrl+c" = "copy_or_interrupt";
        "ctrl+v" = "paste_from_clipboard";
      };
    };

    waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = {
        mainBar = {
          layer = "top";
          # position = "bottom", // Waybar position (top|bottom|left|right)
          # height = 30, // Waybar height (to be removed for auto height)
          # width = 1280, // Waybar width
          # spacing = 4, // Gaps between modules (4px)

          modules-left = [ "tray" ];
          modules-center = [ "custom/media" ];
          modules-right = [
            "custom/brightness"
            "pulseaudio"
            "temperature"
            "cpu"
            "memory"
            "disk"
            "hyprland/language"
            # "custom/weather"
            "clock"
          ];
          tray = {
            icon-size = 19;
            spacing = 10;
          };
          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
            };
            on-click = "activate";
          };
          clock = {
            tooltip-format = "<tt><small>{calendar}</small></tt>";
            format-alt = "{:%d.%m.%Y}";
          };
          cpu = {
            format = "{usage}% 󰍛";
            interval = 2;
          };
          bluetooth = {
            format = "";
            "format-off" = "󰂲"; # an empty format will hide the module
            format-connected = " {device_alias}";
            tooltip-format = "{controller_alias}\t{controller_address}";
            tooltip-format-connected = "{controller_alias}\t{controller_address}\n\n{device_enumerate}";
            tooltip-format-enumerate-connected = "{device_alias}\t{device_address}";
            on-click = "systemctl start bluetooth.service";
            on-click-right = "systemctl stop bluetooth.service";
          };
          memory = {
            format = "{}% ";
          };
          disk = {
            interval = 30;
            format = "{percentage_used}% ";
            path = "/";
          };
          temperature = {
            tooltip = false;
            # "thermal-zone" = 1;
            hwmon-path = "/sys/class/hwmon/hwmon2/temp1_input";
            critical-threshold = 80;
            # "format-critical" = "{temperatureC}°C {icon}";
            format = "{temperatureC}°C {icon}";
            format-icons = [ "" ];
          };
          pulseaudio = {
            # "scroll-step" = 1, // %, can be a float;
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon} ";
            format-bluetooth-muted = " {icon}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            "format-icons" = {
              headphone = "";
              hands-free = "";
              headset = "";
              default = [ "" "" ];
            };
            ignored-sinks = [ "JamesDSP Sink" ];
          };
          "custom/media" = {
            tooltip = false;
            format = "{}";
            interval = 1;
            escape = true;
            exec = pkgs.writeShellScript "get_spotify" ''
              #!/bin/sh

              playback_status=$(playerctl status 2>/dev/null)

              if [ -n "$playback_status" ]; then

              	media=$(playerctl metadata -f "{{artist}} - {{title}}")

              	if [ "$playback_status" = "Playing" ]; then
              		song_status=''
              	else
              		song_status=''
              	fi

              	printf "%s" "$song_status $media"
              fi
            '';
          };
          "hyprland/language" = {
            format = "{}";
            format-en = "EN";
            format-ru = "RU";
          };
          "wlr/taskbar" = {
            format = "{icon}";
            icon-size = 18;
            tooltip = false;
            on-click = "activate";
            on-click-middle = "close";
            ignore-list = [ "Spotify" ];
          };
          "custom/brightness" = {
            tooltip = false;
            format = "{}%  ";
            interval = 2;
            exec = "brillo 2>/dev/null | cut -d '.' -f 1";
          };
          "custom/weather" = {
            tooltip = false;
            format = "{}°C 󰖕";
            exec = "curl -s 'https:#api.open-meteo.com/v1/forecast?latitude=53.90&longitude=27.57&current_weather=true&temperature_2m' | jq '.current_weather.temperature' | xargs printf '%.0f'";
            interval = 1800;
          };
        };
      };

      style = ''
        * {
          font-family: "CaskaydiaCove NF", "JetBrainsMono NF", sans-serif;
          font-size: 16px;
        }

        window#waybar {
          background-color: rgba(0, 0, 0, 255);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: 0.5s;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        /*
        window#waybar.empty {
            background-color: transparent;
        }
        window#waybar.solo {
            background-color: #FFFFFF;
        }
        */

        button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
        }

        /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
        button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button {
          padding: 0 5px;
          background-color: transparent;
          color: #ffffff;
        }

        #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
        }

        #workspaces button.focused {
          background-color: #64727d;
          box-shadow: inset 0 -3px #ffffff;
        }

        #workspaces button.urgent {
          background-color: #eb4d4b;
        }

        #mode {
          background-color: #64727d;
          border-bottom: 3px solid #ffffff;
        }

        #clock,
        #cpu,
        #bluetooth,
        #memory,
        #disk,
        #temperature,
        #backlight,
        #pulseaudio,
        #wireplumber,
        #custom-media,
        #custom-brightness,
        #tray,
        #mode,
        #mpd,
        #custom-vpn,
        #custom-weather,
        #language {
          padding: 0.2em 0.5em;
          color: #000000;
          border-radius: 5px;
          margin: 0.4em 0.3em;
        }

        #window,
        #workspaces {
          margin: 0 4px;
        }

        /* If workspaces is the leftmost module, omit left margin */
        .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
        }

        /* If workspaces is the rightmost module, omit right margin */
        .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
        }

        #clock {
          background-color: #dddddd;
        }

        @keyframes blink {
          to {
            background-color: #ffffff;
            color: #000000;
          }
        }

        label:focus {
          background-color: #000000;
        }

        #cpu {
          background-color: #2ecc71;
        }

        #bluetooth {
          background-color: #006cff;
        }

        #memory {
          background-color: #9b59b6;
        }

        #disk {
          background-color: #f476ff;
        }

        #backlight {
          background-color: #90b1b1;
        }

        #network {
          background-color: #2980b9;
        }

        #network.disconnected {
          background-color: #f53c3c;
        }

        #pulseaudio {
          background-color: #f1c40f;
        }

        #pulseaudio.muted {
          background-color: #90b1b1;
        }

        #wireplumber {
          background-color: #f1c40f;
        }

        #wireplumber.muted {
          background-color: #f53c3c;
        }

        #custom-media {
          background-color: #66cc99;
          min-width: 0px;
        }

        #custom-media.custom-spotify {
          background-color: #66cc99;
        }

        #custom-media.custom-vlc {
          background-color: #ffa000;
        }

        #temperature {
          background-color: #00d9e0;
        }

        #temperature.critical {
          background-color: #eb4d4b;
        }

        #tray {
          background-color: #000000;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
        }

        #mpd {
          background-color: #66cc99;
          color: #2a5c45;
        }

        #mpd.disconnected {
          background-color: #f53c3c;
        }

        #mpd.stopped {
          background-color: #90b1b1;
        }

        #mpd.paused {
          background-color: #51a37a;
        }

        #language {
          background: #00b093;
          min-width: 18px;
        }

        #custom-brightness {
          background-color: #90b1b1;
        }

        #custom-vpn {
          background-color: #ff0084;
        }

        #custom-weather {
          background-color: #7287fd;
        }

      '';
    };

    rofi = {
      enable = true;
      package = pkgs.rofi-wayland;
      font = "JetBrainsMono NF 14";
      location = "center";
      plugins = [ pkgs.rofi-calc ];
      extraConfig = {
        modes = "drun";
        fixed-num-lines = false;
        show-icons = true;
        kb-cancel = "Escape,MousePrimary";
      };
    };

    lf = {
      enable = true;
      settings = {
        cursorpreviewfmt = "";
        drawbox = true;
        hidden = true;
        icons = true;
        ifs = "\n";
        info = [ "size" "time" ];
        mouse = true;
        ratios = [ 1 2 ];
        statfmt = "\033[35m %s| \033[34m %t| \033[36m %l| \033[0m";
        rulerfmt = "%a  |%p  |\033[7;31m %m \033[0m  |\033[7;33m %c \033[0m  |\033[7;35m %s \033[0m  |\033[7;34m %f | \033[35m %d | \033[0m %i/%t";
        scrolloff = 10;
        shell = "sh";
        shellopts = "-eu";
        sortby = "ext";

        # cleaner = pkgs.writeShellScript "cl.sh" ''
        #   #!/usr/bin/env bash

        #   kitty +kitten icat --clear --stdin no --silent --transfer-mode file < /dev/null > /dev/tty
        # '';
      };
      previewer.source = pkgs.writeShellScript "pv.sh" ''
        #!/usr/bin/env bash
        
        file=$1
        w=$2
        h=$3
        x=$4
        y=$5

        if [[ "$( file -Lb --mime-type "$file")" =~ ^image ]]; then
            kitty +kitten icat --silent --stdin no --transfer-mode file --place "''${w}x''${h}@''${x}x''${y}" "$file" < /dev/null > /dev/tty
            exit 1
        fi

        bat --color always "$file"
      '';
    };

    mangohud = {
      enable = true;
      settings = {
        cpu_stats = true;
        cpu_temp = true;
        fps = true;
        frame_timing = true;
        frametime = true;
        gamemode = true;
        gpu_stats = true;
        gpu_temp = true;
        round_corners = 10;
        text_outline = true;
        toggle_hud = "Control_L + H";
        vram = true;
      };
    };
  };

  services = {
    dunst = {
      enable = true;
    };

    gammastep = {
      enable = true;
      provider = "manual";
      latitude = 53.9;
      longitude = 27.57;
      temperature.day = 6500;
      temperature.night = 2500;
    };
  };

  gtk = {
    enable = true;

    theme = {
      package =
        (pkgs.colloid-gtk-theme.override {
          themeVariants = [ "pink" ];
          colorVariants = [ "dark" ];
          sizeVariants = [ "compact" ];
          tweaks = [ "black" "normal" ];
        });
      name = "Colloid-Pink-Dark-Compact";
    };

    iconTheme = {
      package =
        (pkgs.papirus-icon-theme.override {
          color = "pink";
        });
      name = "Papirus-Dark";
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 10;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}
