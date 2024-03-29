local wezterm = require("wezterm")
local config = {

	color_scheme = "Monokai Soda",
	enable_tab_bar = false,
	font = wezterm.font("IosevkaTerm Nerd Font"),
	font_size = 15,
	force_reverse_video_cursor = true,
	freetype_load_flags = "NO_HINTING",
	window_close_confirmation = "NeverPrompt",
	window_background_opacity = 0.9,

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
		{
			key = "x",
			mods = "SHIFT|CTRL",
			action = wezterm.action.DisableDefaultAssignment,
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
