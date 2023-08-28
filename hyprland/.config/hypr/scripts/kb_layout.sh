#!/bin/bash
active_window_class=""
previous_window_class=""

kb_names="bastard-keyboards-charybdis-mini-(3x6)-pro-micro hyperpuncher-kanariyoi"

active_keyboard=""

en_layout_apps="code-url-handler kitty firefox obsidian"
ru_layout_apps="org.telegram.desktop"

for name in ${kb_names}; do
    if hyprctl devices -j | jq -e '.keyboards[].name' | grep -q "$name"; then
        active_keyboard="$name"
        break
    fi
done

while true; do
    active_window_class=$(hyprctl activewindow | grep "class" | awk '{print $2}')
    if [ "$active_window_class" != "$previous_window_class" ]; then
        case " $en_layout_apps " in
        *" $active_window_class "*)
            hyprctl switchxkblayout "$active_keyboard" 0
            ;;
        esac
        case " $ru_layout_apps " in
        *" $active_window_class "*)
            hyprctl switchxkblayout "$active_keyboard" 1
            ;;
        esac
        previous_window_class="$active_window_class"
    fi
    sleep 0.2
done
