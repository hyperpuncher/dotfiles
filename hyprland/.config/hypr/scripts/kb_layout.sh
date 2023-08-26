#!/bin/dash
active_window_class=""
previous_window_class=""

en_layout_apps="code-url-handler kitty firefox obsidian"
ru_layout_apps="org.telegram.desktop"

while true; do
    active_window_class=$(hyprctl activewindow | grep "class" | awk '{print $2}')
    if [ "$active_window_class" != "$previous_window_class" ]; then
        case " $en_layout_apps " in
        *" $active_window_class "*)
            hyprctl switchxkblayout hyperpuncher-kanariyoi-keyboard 0
            ;;
        esac
        case " $ru_layout_apps " in
        *" $active_window_class "*)
            hyprctl switchxkblayout hyperpuncher-kanariyoi-keyboard 1
            ;;
        esac
        previous_window_class="$active_window_class"
    fi
    sleep 1
done
