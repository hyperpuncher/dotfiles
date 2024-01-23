{ pkgs, ... }:

{
  home = {
    username = "igor";
    homeDirectory = "/home/igor";
    stateVersion = "23.11";
    packages = [ ];
    sessionVariables = {
      # EDITOR = "emacs";
    };
    file = {
      ".zshrc".source = ../zsh/.zshrc;
      ".zshenv".source = ../zsh/.zshenv;
      ".p10k.zsh".source = ../zsh/.p10k.zsh;
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

      general = {
        gaps_in = -1;
        gaps_out = 0;
        border_size = 1;
        "col.active_border" = "rgb(ffffff)";
        "col.inactive_border" = "rgb(262626)";
      };

      windowrule = [
        "float, ^(blueman-manager)$"
        "float, ^(com\.github.parnold_x\.nasc)$"
        "float, ^(quickgui)$"
        "float, title:^(File Operation Progress)$"
        "pseudo, ^(info.mumble.Mumble)$"
        "tile, ^(qemu-system-x86_64)$"
        "workspace 3 silent, title:^(Telegram.*)$"
      ];

      input = {
        kb_layout = "us,ru";
        kb_options = "grp:rctrl_toggle";
        follow_mouse = 1;
        repeat_delay = 450;
      };

      decoration = {
        blur = {
          size = 2;
          passes = 2;
        };

        shadow_range = 10;
        shadow_offset = "3 4";
        "col.shadow" = "rgba(00000060)";
        "col.shadow_inactive" = "rgba(00000000)";
      };

      animations = {
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.0";
        animation = [
          "windows, 1, 4, myBezier"
          "windowsOut, 1, 7, default"
          "border, 1, 5, default"
          "fade, 1, 3, default"
          "workspaces, 0, 2, default"
        ];
      };

      bind = [
        "$mod, ESCAPE, exec, ~/.config/rofi/scripts/power_menu.sh"
        "$mod, RETURN, exec, wezterm"
        "$mod, E, exec, thunar"
        "$mod, B, exec, firefox"
        "$mod, K, exec, hyprctl kill"
        "$mod, D, exec, rofi -show drun -display-drun 'Apps'"
        "$mod, Q, killactive,"
        "$mod, P, pseudo, # dwindle"
        "$mod, J, togglesplit, # dwindle"
        "$mod, F, fullscreen"
        "$mod SHIFT, F, togglefloating"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"


        "$mod, g, workspace, 1"
        "$mod, c, workspace, 2"
        "$mod, t, workspace, 3"
        "$mod, s, workspace, 4"
        "$mod, r, workspace, 5"
        "$mod, a, workspace, 6"
        "$mod, z, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        "$mod SHIFT, g, movetoworkspacesilent, 1"
        "$mod SHIFT, c, movetoworkspacesilent, 2"
        "$mod SHIFT, t, movetoworkspacesilent, 3"
        "$mod SHIFT, s, movetoworkspacesilent, 4"
        "$mod SHIFT, r, movetoworkspacesilent, 5"
        "$mod SHIFT, a, movetoworkspacesilent, 6"
        "$mod SHIFT, z, movetoworkspacesilent, 7"
        "$mod SHIFT, 8, movetoworkspacesilent, 8"
        "$mod SHIFT, 9, movetoworkspacesilent, 9"
        "$mod SHIFT, 0, movetoworkspacesilent, 10"

        ", XF86MonBrightnessDown, exec, brillo -q -U 5"
        ", XF86MonBrightnessUp, exec, brillo -q -A 5"

        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"

        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_SINK@ 5%+"

        # Clipboard
        "$mod, V, exec, cliphist list | rofi -dmenu -p 'clipboard' -display-columns 2 | cliphist decode | wl-copy"

      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
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
      difftastic.enable = true;
      extraConfig = {
        credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
      };
    };

    kitty = {
      enable = true;
      font.name = "Iosevka Nerd Font";
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

    wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require("wezterm")
        local config = {

            animation_fps = 30,
            audible_bell = "Disabled",
            color_scheme = "Monokai Soda",
            default_cursor_style = "BlinkingBar",
            enable_tab_bar = false,
            enable_wayland = false,
            font = wezterm.font("IosevkaTerm Nerd Font"),
            font_size = 15,
            freetype_load_flags = "NO_HINTING",
            window_close_confirmation = "NeverPrompt",

            colors = {
                cursor_fg = "black",
            },

            keys = {
                {
                    key = "c",
                    mods = "CTRL",
                    action = wezterm.action_callback(function(window, pane)
                        local has_selection = window:get_selection_text_for_pane(pane) ~= ""
                        if has_selection then
                            window:perform_action(wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }), pane)
                            window:perform_action("ClearSelection", pane)
                        else
                            window:perform_action(wezterm.action({ SendKey = { key = "c", mods = "CTRL" } }), pane)
                        end
                    end),
                },
                {
                    key = "v",
                    mods = "CTRL",
                    action = wezterm.action_callback(function(window, pane)
                        if pane:get_foreground_process_name() ~= "/usr/bin/nvim" then
                            window:perform_action(wezterm.action({ PasteFrom = "Clipboard" }), pane)
                        else
                            window:perform_action(wezterm.action.SendKey({ key = "v", mods = "CTRL" }), pane)
                        end
                    end),
                },
            },

            mouse_bindings = {
                {
                    event = { Down = { streak = 1, button = "Middle" } },
                    mods = "NONE",
                    action = wezterm.action.Nop,
                },
            },
        }

        return config
      '';
    };

    /* vscode = {
      enable = true;
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
      jnoortheen.nix-ide
      sumneko.lua
      asvetliakov.vscode-neovim
      ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
      name = "aura-theme";
      publisher = "DaltonMenezes";
      version = "latest";
      sha256 = "sha256-r6pPpvJ1AZsM0RYF+xHsZ4b4QTszN+wELr1SENsUDFA=";
      }
      ];

      userSettings = {

      "editor.fontFamily" = "JetBrainsMono Nerd Font";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 18;
      "extensions.experimental.affinity" = {
      "asvetliakov.vscode-neovim" = 1;
      };
      "nix.enableLanguageServer" = true;
      "window.menuBarVisibility" = "hidden";
      "window.titleBarStyle" = "custom";
      "workbench.colorTheme" = "Aura Dark";

      };
      }; */

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
          font-family: "CaskaydiaCove NF", sans-serif;
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
      font = "Inter Display 15";
      location = "center";
      plugins = [ pkgs.rofi-calc ];
      theme = {
        window = {
          width = "25%";
        };
      };
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
      };
      previewer.source = "${pkgs.ctpv}/bin/ctpv";
      extraConfig = ''
        &${pkgs.ctpv}/bin/ctpv -s $id
        cmd on-quit %${pkgs.ctpv}/bin/ctpv -e $id
        set cleaner ${pkgs.ctpv}/bin/ctpvclear
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
    udiskie.enable = true;

    dunst = {
      enable = true;
      settings = {
        global = {
          width = "(0, 300)";
          offset = "30x30";
          frame_width = 1;
          frame_color = "#000000";
          font = "Inter Display 10";
          icon_theme = "Papirus-Dark";
        };
        urgency_normal = {
          background = "#ffffff";
          foreground = "#0f0f0f";
        };
      };
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
        pkgs.colloid-gtk-theme.override {
          themeVariants = [ "pink" ];
          colorVariants = [ "dark" ];
          sizeVariants = [ "compact" ];
          tweaks = [ "black" "normal" ];
        };
      name = "Colloid-Pink-Dark-Compact";
    };

    iconTheme = {
      package =
        pkgs.papirus-icon-theme.override {
          color = "pink";
        };
      name = "Papirus-Dark";
    };

    font = {
      name = "Inter Display";
      size = 11;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };
}
