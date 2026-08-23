local terminal = "foot"
local file_manager = "nemo"
local browser = "helium-browser"

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
	for _, command in ipairs({
		"runapp mpv --loop=no ~/dotfiles/sounds/silent.wav",
		"runapp ~/projects/arduino/autobrightness/autobrightness",
		"runapp wlsunset -t 3000 -T 6500 -l 53.9 -L 27.6 -d 1800",
		"runapp darkman run",
		"runapp qs",
		"runapp udiskie",
		"runapp corectrl",
		"runapp jamesdsp -t",
		"runapp localsend --hidden",
		"runapp /usr/bin/hyprland-per-window-layout",
	}) do
		hl.exec_cmd(command)
	end
end)

hl.on("hyprland.shutdown", function()
	hl.exec_cmd("rift clear")
end)

-- window rules

local window_rules = {
	{
		name = "suppress-maximize-events",
		match = { class = ".*" },
		suppress_event = "maximize",
	},
	{
		name = "telegram",
		match = { class = "org.telegram.desktop" },
		workspace = "3 silent",
		pseudo = true,
		size = { 1002, 1392 },
	},
	{
		name = "mumble",
		match = { class = "info.mumble.Mumble" },
		pseudo = true,
		size = { 773, 498 },
	},
	{
		name = "signal",
		match = { class = "signal" },
		pseudo = true,
		size = { 874, 1212 },
	},
	{
		name = "transmission",
		match = { class = "com.transmissionbt.*" },
		pseudo = true,
		size = { 950, 550 },
	},
	{
		name = "spotify",
		match = { class = "spotify" },
		workspace = "4",
	},
	{
		name = "steam",
		match = { class = "steam" },
		workspace = "5 silent",
	},
	{
		name = "file-operation-progress",
		match = { title = "^File Operation Progress$" },
		float = true,
	},
	{
		name = "dev-linux-amd64",
		match = { class = "^.*dev-linux-amd64$" },
		float = true,
	},
	{
		name = "qemu-system-x86_64",
		match = { class = "qemu-system-x86_64" },
		tile = true,
	},
	{
		name = "vtk",
		match = { class = "Vtk" },
		tile = true,
	},
	{
		name = "foot",
		match = { class = "foot" },
		size = { 1249, 1426 },
	},
	{
		name = "croc-gui",
		match = { class = "croc-gui" },
		float = true,
	},
	{
		name = "gnome-file-roller",
		match = { class = "org.gnome.FileRoller" },
		float = true,
	},
	{
		name = "emulator",
		match = { class = "Emulator" },
		float = true,
	},
}

for _, rule in ipairs(window_rules) do
	hl.window_rule(rule)
end

-- workspaces

hl.workspace_rule({
	workspace = "special:notes",
	on_created_empty = "[pseudo; size 950 1200] foot -D ~/Documents/notes nvim",
})

hl.workspace_rule({
	workspace = "special:calculator",
	on_created_empty = "[pseudo; size 700 800] foot numr",
})

-- layer rules

hl.layer_rule({
	name = "quickshell-pickers",
	match = {
		namespace = "quickshell-(launcher|clipboard|bluetooth|power|emoji|network|audio|notification-center|polkit|calendar)",
	},
	blur = true,
	ignore_alpha = 0.5,
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
		gaps_in = 1,
		gaps_out = 4,
		border_size = 3,
		col = {
			inactive_border = "rgba(50,50,50,0)",
			active_border = "rgba(222,222,222,0.5)",
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
			render_power = 4,
			color = "rgba(00000030)",
			offset = { 0, 8 },
			scale = 0.97,
		},
		rounding = 9,
		rounding_power = 2.25,
	},

	animations = {
		enabled = true,
	},
})

hl.curve("easeOut", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOut", { type = "bezier", points = { { 0.77, 0 }, { 0.175, 1 } } })

-- Keep occasional transitions subtle and fast; frequent keyboard navigation stays instant.
local animation_rules = {
	{ leaf = "global", enabled = true, speed = 1.2, bezier = "easeOut" },
	{ leaf = "border", enabled = false },

	{ leaf = "windows", enabled = true, speed = 1.2, bezier = "easeOut" },
	{ leaf = "windowsIn", enabled = true, speed = 1.6, bezier = "easeOut", style = "popin 95%" },
	{ leaf = "windowsOut", enabled = true, speed = 1, bezier = "easeOut", style = "popin 95%" },
	{ leaf = "windowsMove", enabled = true, speed = 1.2, bezier = "easeInOut" },

	{ leaf = "fade", enabled = true, speed = 1, bezier = "easeOut" },
	{ leaf = "fadeIn", enabled = true, speed = 1.2, bezier = "easeOut" },
	{ leaf = "fadeOut", enabled = true, speed = 0.8, bezier = "easeOut" },
	{ leaf = "fadeSwitch", enabled = false },
	{ leaf = "fadeShadow", enabled = false },

	{ leaf = "layers", enabled = true, speed = 1.2, bezier = "easeOut" },
	{ leaf = "layersIn", enabled = true, speed = 1.2, bezier = "easeOut", style = "fade" },
	{ leaf = "layersOut", enabled = true, speed = 0.8, bezier = "easeOut", style = "fade" },

	{ leaf = "workspaces", enabled = false },
}

for _, rule in ipairs(animation_rules) do
	hl.animation(rule)
end

-- binds

local mod = "SUPER"

local function mod_bind(keys, dispatcher, options)
	hl.bind(mod .. " + " .. keys, dispatcher, options)
end

-- apps and shell

mod_bind("ESCAPE", hl.dsp.global("quickshell:power"))
mod_bind("RETURN", hl.dsp.exec_cmd(terminal))
mod_bind("e", hl.dsp.exec_cmd(file_manager))
mod_bind("b", hl.dsp.exec_cmd(browser))
mod_bind("d", hl.dsp.global("quickshell:launcher"))
mod_bind("bracketleft", hl.dsp.global("quickshell:emoji"))
mod_bind("bracketright", hl.dsp.exec_cmd("shopot"))

-- windows

mod_bind("SHIFT + k", hl.dsp.window.kill())
mod_bind("q", hl.dsp.window.close())
mod_bind("p", hl.dsp.window.pseudo())
mod_bind("f", hl.dsp.window.fullscreen({ mode = "maximized" }))
mod_bind("SHIFT + f", hl.dsp.window.float())

for _, bind in ipairs({
	{ key = "h", direction = "l", resize = { -50, 0 } },
	{ key = "l", direction = "r", resize = { 50, 0 } },
	{ key = "k", direction = "u", resize = { 0, -50 } },
	{ key = "j", direction = "d", resize = { 0, 50 } },
}) do
	mod_bind(bind.key, hl.dsp.focus({ direction = bind.direction }))
	mod_bind("CTRL + " .. bind.key, hl.dsp.window.move({ direction = bind.direction }))
	hl.bind(
		"ALT + " .. bind.key,
		hl.dsp.window.resize({ x = bind.resize[1], y = bind.resize[2], relative = true }),
		{ repeating = true }
	)
end

mod_bind("mouse:272", hl.dsp.window.drag(), { mouse = true })
mod_bind("mouse:273", hl.dsp.window.resize(), { mouse = true })

-- workspaces

for workspace, key in ipairs({ "g", "r", "t", "s", "w" }) do
	local name = tostring(workspace)
	mod_bind(key, hl.dsp.focus({ workspace = name }))
	mod_bind("SHIFT + " .. key, hl.dsp.window.move({ workspace = name, follow = false }))
end

mod_bind("n", hl.dsp.workspace.toggle_special("notes"))
mod_bind("m", hl.dsp.workspace.toggle_special("calculator"))

-- app shortcuts

mod_bind("c", hl.dsp.send_shortcut({ mods = "CTRL", key = "Insert" }))
mod_bind("v", hl.dsp.send_shortcut({ mods = "SHIFT", key = "Insert" }))
mod_bind("a", hl.dsp.send_shortcut({ mods = "CTRL", key = "a" }))
mod_bind("x", hl.dsp.send_shortcut({ mods = "CTRL", key = "x" }))
mod_bind("z", hl.dsp.send_shortcut({ mods = "CTRL", key = "z" }))
mod_bind("SHIFT + v", hl.dsp.global("quickshell:clipboard"))

-- media and display

hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl --player=spotify play-pause"))
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl --player=spotify next"))
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl --player=spotify previous"))

hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%-"), { repeating = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_SINK@ 5%+"), { repeating = true })

hl.bind(
	"XF86MonBrightnessDown",
	hl.dsp.exec_cmd("ddcutil --skip-ddc-checks --noverify setvcp 10 - 5"),
	{ repeating = true }
)
hl.bind(
	"XF86MonBrightnessUp",
	hl.dsp.exec_cmd("ddcutil --skip-ddc-checks --noverify setvcp 10 + 5"),
	{ repeating = true }
)

-- screenshots and utilities

mod_bind("comma", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -f"))
mod_bind("period", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -w"))
mod_bind("slash", hl.dsp.exec_cmd("~/dotfiles/scripts/screenshot -s"))

mod_bind("CTRL + comma", hl.dsp.global("quickshell:screenshot-fullscreen"))
mod_bind("CTRL + period", hl.dsp.global("quickshell:screenshot-window"))
mod_bind("CTRL + slash", hl.dsp.global("quickshell:screenshot"))
mod_bind("CTRL + c", hl.dsp.exec_cmd("hyprpicker -a"))

-- misc

hl.config({
	misc = {
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		vrr = 0,
		middle_click_paste = false,
	},

	cursor = {
		hide_on_key_press = true,
	},

	xwayland = {
		force_zero_scaling = true,
	},
})
