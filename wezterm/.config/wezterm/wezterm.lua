local wezterm = require 'wezterm'
local config = {

    animation_fps = 30,
    color_scheme = 'Monokai Soda',
    default_cursor_style = "BlinkingBar",
    enable_tab_bar = false,
    font = wezterm.font 'JetBrainsMono Nerd Font',
    font_size = 14,
    freetype_load_flags = 'NO_HINTING',
    front_end = "OpenGL",
    window_close_confirmation = "NeverPrompt",

    keys = {
        {
            key = "c",
            mods = "CTRL",
            action = wezterm.action_callback(function(window, pane)
                local has_selection = window:get_selection_text_for_pane(pane) ~= ""
                if has_selection then
                    window:perform_action(
                        wezterm.action { CopyTo = "ClipboardAndPrimarySelection" },
                        pane)
                    window:perform_action("ClearSelection", pane)
                else
                    window:perform_action(
                        wezterm.action { SendKey = { key = "c", mods = "CTRL" } },
                        pane)
                end
            end)
        },
        {
            key = "v",
            mods = "CTRL",
            action = wezterm.action { PasteFrom = "Clipboard" },
        },
    },
}

return config
