local terminal = "foot"
local file_manager = "nemo"
local browser = "zen-browser"

-- monitor

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "1.5",
	bitdepth = 10,
})

-- exec

hl.on("hyprland.start", function()
	hl.exec_cmd("runapp mpv --loop=no ~/dotfiles/sounds/silent.wav")
	hl.exec_cmd("runapp ~/projects/arduino/autobrightness/autobrightness")
	hl.exec_cmd("runapp wlsunset -t 3000 -T 6500 -l 53.9 -L 27.6 -d 1800")
	hl.exec_cmd("runapp darkman run")
	hl.exec_cmd("runapp waybar")
	hl.exec_cmd("runapp /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("runapp udiskie")
	hl.exec_cmd("runapp mako")
	hl.exec_cmd("runapp corectrl")
	hl.exec_cmd("runapp jamesdsp -t")
	hl.exec_cmd("runapp blueman-applet")
	hl.exec_cmd("runapp nm-applet")
	hl.exec_cmd("runapp localsend --hidden")
	hl.exec_cmd("runapp /usr/bin/hyprland-per-window-layout")
	hl.exec_cmd("runapp wl-clip-persist --clipboard regular")
	hl.exec_cmd("runapp wl-paste --type text --watch cliphist store")
	hl.exec_cmd("runapp wl-paste --type image --watch cliphist store")
	hl.exec_cmd("runapp hypridle")
end)

-- window rules

local suppressMaximizeRule = hl.window_rule({
	name = "suppress-maximize-events",
	match = { class = ".*" },
	suppress_event = "maximize",
})
suppressMaximizeRule:set_enabled(true)

hl.window_rule({
	name = "telegram",
	match = { class = "org.telegram.desktop" },
	workspace = 3,
	pseudo = true,
	size = { 1002, 1392 },
})

hl.window_rule({
	name = "mumble",
	match = { class = "info.mumble.Mumble" },
	pseudo = true,
	size = { 773, 498 },
})

hl.window_rule({
	name = "signal",
	match = { class = "signal" },
	pseudo = true,
	size = { 874, 1212 },
})

hl.window_rule({
	name = "blueman",
	match = { class = "blueman-manager" },
	float = true,
	center = true,
	size = { 529, 344 },
})

hl.window_rule({
	name = "transmission",
	match = { class = "com.transmissionbt.*" },
	pseudo = true,
	size = { 950, 550 },
})

hl.window_rule({
	name = "spotify",
	match = { class = "spotify" },
	workspace = 4,
})

hl.window_rule({
	name = "steam",
	match = { class = "steam" },
	workspace = 5,
})

hl.window_rule({
	name = "file-operation-progress",
	match = { title = "^File Operation Progress$" },
	float = true,
})

hl.window_rule({
	name = "dev-linux-amd64",
	match = { class = "^.*dev-linux-amd64$" },
	float = true,
})

hl.window_rule({
	name = "qemu-system-x86_64",
	match = { class = "qemu-system-x86_64" },
	tile = true,
})

hl.window_rule({
	name = "vtk",
	match = { class = "Vtk" },
	tile = true,
})

hl.window_rule({
	name = "foot",
	match = { class = "foot" },
	size = { 1416, 1416 },
})

hl.window_rule({
	name = "croc-gui",
	match = { class = "croc-gui" },
	float = true,
})

hl.window_rule({
	name = "gnome-file-roller",
	match = { class = "org.gnome.FileRoller" },
	float = true,
})

-- workspaces

hl.workspace_rule({
	workspace = "special:notes",
	on_created_empty = "[pseudo; size 950 1200] foot -D ~/Documents/notes nvim",
})

hl.workspace_rule({
	workspace = "special:calculator",
	on_created_empty = "[pseudo; size 700 800] foot numr",
})

hl.workspace_rule({
	workspace = "special:chatski",
	on_created_empty = "[pseudo; size 1200 1400] ~/projects/chatski/dist/linux-unpacked/chatski",
})

-- layer rules

hl.layer_rule({
	name = "rofi",
	match = { namespace = "rofi" },
	blur = true,
	ignore_alpha = 0,
	no_anim = true,
})

-- input

hl.config({
	input = {
		kb_layout = "us,ru",
		kb_options = "grp:rctrl_toggle",
		follow_mouse = 1,
		repeat_delay = 300,
		repeat_rate = 40,
		accel_profile = "flat",
		numlock_by_default = true,
	},
})

hl.device({
	name = "bastard-keyboards-charybdis-mini-(3x6)-pro-micro-1",
	sensitivity = 0.5,
})

hl.device({
	name = "nordic-2.4g-wireless-receiver-mouse",
	sensitivity = 0,
})

hl.device({
	name = "logitech-ergo-m575",
	sensitivity = -0.5,
})

-- look and feel

hl.config({
	general = {
		gaps_in = 2,
		gaps_out = 4,
		border_size = 3,
		col = {
			inactive_border = "rgba(0,0,0,170)",
			active_border = "rgba(255,255,255,170)",
		},
	},

	decoration = {
		blur = {
			enabled = true,
			size = 4,
			passes = 2,
		},
		shadow = {
			enabled = true,
			range = 40,
			render_power = 3,
			color = "rgba(00000050)",
			offset = { 0, 0 },
			scale = 0.99,
		},
		rounding = 9,
		rounding_power = 2.25,
	},

	animations = {
		enabled = true,
	},
})

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })

hl.curve("easy", { type = "spring", mass = 1, stiffness = 71.2633, dampening = 15.8273644 })

hl.animation({ leaf = "global", enabled = true, speed = 10, bezier = "default" })
hl.animation({ leaf = "border", enabled = false, speed = 1.8, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows", enabled = true, speed = 3.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.1, bezier = "easeOutQuint", transition = "popin 87%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.49, bezier = "linear", transition = "popin 87%" })
hl.animation({ leaf = "fadeIn", enabled = false, speed = 0.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade", enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers", enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 1, bezier = "easeOutQuint", transition = "fade" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.5, bezier = "linear", transition = "fade" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 0.5, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 1.2, bezier = "almostLinear", transition = "fade" })
hl.animation({ leaf = "workspacesIn", enabled = false, speed = 0.2, bezier = "almostLinear", transition = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = false, speed = 0.8, bezier = "almostLinear", transition = "fade" })

-- binds

local mod = "SUPER"

hl.bind(
	mod .. " + ESCAPE",
	hl.dsp.exec_cmd(
		"rofi -show power_menu -modes 'power_menu:~/dotfiles/rofi/.config/rofi/scripts/power_menu.sh' -theme-str 'window {width: 15%;}' -no-show-icons"
	)
)
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + e", hl.dsp.exec_cmd(file_manager))
hl.bind(mod .. " + b", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + x", hl.dsp.window.kill())
hl.bind(mod .. " + d", hl.dsp.exec_cmd("rofi -show drun -display-drun 'apps' -run-command 'runapp {cmd}'"))
hl.bind(mod .. " + q", hl.dsp.window.close())
hl.bind(mod .. " + p", hl.dsp.window.pseudo())
hl.bind(mod .. " + f", hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + f", hl.dsp.window.float())
hl.bind(mod .. " + bracketleft", hl.dsp.exec_cmd("rofi -show emoji"))

hl.bind(mod .. " + c", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
hl.bind(mod .. " + v", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
hl.bind(mod .. " + a", hl.dsp.send_shortcut({ mods = "CTRL", key = "a" }))
hl.bind(mod .. " + z", hl.dsp.send_shortcut({ mods = "CTRL", key = "z" }))

hl.bind(mod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mod .. " + j", hl.dsp.focus({ direction = "d" }))

hl.bind(mod .. " + CTRL + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mod .. " + CTRL + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mod .. " + CTRL + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mod .. " + CTRL + j", hl.dsp.window.move({ direction = "d" }))

hl.bind("ALT + h", hl.dsp.window.resize({ x = -50, y = 0 }))
hl.bind("ALT + l", hl.dsp.window.resize({ x = 50, y = 0 }))
hl.bind("ALT + k", hl.dsp.window.resize({ x = 0, y = -50 }))
hl.bind("ALT + j", hl.dsp.window.resize({ x = 0, y = 50 }))

hl.bind(mod .. " + g", hl.dsp.focus({ workspace = "1" }))
hl.bind(mod .. " + r", hl.dsp.focus({ workspace = "2" }))
hl.bind(mod .. " + t", hl.dsp.focus({ workspace = "3" }))
hl.bind(mod .. " + s", hl.dsp.focus({ workspace = "4" }))
hl.bind(mod .. " + w", hl.dsp.focus({ workspace = "5" }))

hl.bind(mod .. " + SHIFT + g", hl.dsp.window.move({ workspace = "1" }))
hl.bind(mod .. " + SHIFT + r", hl.dsp.window.move({ workspace = "2" }))
hl.bind(mod .. " + SHIFT + t", hl.dsp.window.move({ workspace = "3" }))
hl.bind(mod .. " + SHIFT + s", hl.dsp.window.move({ workspace = "4" }))
hl.bind(mod .. " + SHIFT + w", hl.dsp.window.move({ workspace = "5" }))

hl.bind(mod .. " + n", hl.dsp.workspace.toggle_special({ "notes" }))
hl.bind(mod .. " + m", hl.dsp.workspace.toggle_special({ "calculator" }))
hl.bind(mod .. " + a", hl.dsp.workspace.toggle_special({ "chatski" }))

hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.2 @DEFAULT_SINK@ 5%+"))

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("ddcutil --skip-ddc-checks --noverify setvcp 10 - 5"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("ddcutil --skip-ddc-checks --noverify setvcp 10 + 5"))

hl.bind(mod .. " + comma", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -f"))
hl.bind(mod .. " + period", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -w"))
hl.bind(mod .. " + slash", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -s"))
hl.bind(mod .. " + SHIFT + comma", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -f -e"))
hl.bind(mod .. " + SHIFT + period", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -w -e"))
hl.bind(mod .. " + SHIFT + slash", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -s -e"))

hl.bind(mod .. " + CTRL + c", hl.dsp.exec_cmd("hyprpicker -a"))

hl.bind(
	mod .. " + SHIFT + v",
	hl.dsp.exec_cmd(
		"rofi -modi clipboard:~/dotfiles/rofi/.config/rofi/scripts/cliphist-rofi-img -show clipboard -show-icons -theme-str 'window {width: 30%;}'"
	)
)

hl.bind(mod .. " + bracketright", hl.dsp.exec_cmd("shopot"))
hl.bind(mod .. " + i", hl.dsp.exec_cmd("~/projects/chatski/dist/linux-unpacked/chatski"))

-- misc

hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 1,
		middle_click_paste = false,
	},

	cursor = {
		hide_on_key_press = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})
