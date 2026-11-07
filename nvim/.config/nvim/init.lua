local opt = vim.o
local map = vim.keymap.set
local hl = vim.api.nvim_set_hl
local autocmd = vim.api.nvim_create_autocmd

vim.g.mapleader = " "

opt.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal"
opt.winborder = "rounded"
opt.pumborder = "rounded"
opt.cursorline = true
opt.breakindent = true
opt.linebreak = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menuone,noselect,fuzzy"
opt.hlsearch = false
opt.ignorecase = true
opt.inccommand = "split"
opt.mouse = "a"
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.scrolloff = 99
opt.scrolloffpad = 1
opt.shiftround = true
opt.shiftwidth = 4
opt.shortmess = opt.shortmess .. "I"
opt.showmode = false
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 4
opt.splitright = true
opt.swapfile = false
opt.tabstop = 4
opt.termguicolors = true
opt.timeoutlen = 500
opt.undofile = true
opt.updatetime = 200
opt.laststatus = 3
opt.foldlevel = 99
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
opt.langmap =
	"ФИСВУАПРШОЛДЬТЩЗЙКЫЕГМЦЧНЯ;ABCDEFGHIJKLMNOPQRSTUVWXYZ,фисвуапршолдьтщзйкыегмцчня;abcdefghijklmnopqrstuvwxyz"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

local servers = {
	astro = {},
	bashls = {},
	clangd = { filetypes = { "c", "cpp", "arduino", "h", "hpp" } },
	cssls = {},
	gopls = {},
	html = {},
	htmx = { filetypes = { "templ" } },
	jsonls = {
		settings = {
			json = {
				allowTrailingCommas = true,
				allowComments = true,
			},
		},
	},
	lua_ls = {
		settings = {
			Lua = {
				workspace = {
					library = {
						"/usr/share/hypr/stubs",
						vim.env.VIMRUNTIME,
					},
				},
				diagnostics = { globals = { "hl", "vim" } },
			},
		},
	},
	marksman = {},
	ols = {},
	openscad_lsp = {},
	basedpyright = {
		settings = {
			basedpyright = {
				disableOrganizeImports = true,
				analysis = {
					typeCheckingMode = "standard",
				},
			},
		},
	},
	ruff = {},
	qmlls = {},
	rust_analyzer = {},
	sqls = {},
	svelte = {},
	tailwindcss = {},
	templ = {},
	tinymist = {},
	tsc = {},
	yamlls = {},
}

local formatters = {
	"gofumpt",
	"kulala-fmt",
	"oxfmt",
	"prettierd",
	"rustywind",
	"shfmt",
	"stylua",
	"templ",
	"typstyle",
	"xmlformatter",
}

local linters = {
	"shellcheck",
	"oxlint",
}

local parsers = {
	"astro",
	"bash",
	"c",
	"comment",
	"cpp",
	"css",
	"desktop",
	"dockerfile",
	"git_config",
	"gitignore",
	"go",
	"html",
	"http",
	"hurl",
	"hyprlang",
	"ini",
	"javascript",
	"jq",
	"json",
	"jsx",
	"just",
	"lua",
	"make",
	"markdown",
	"odin",
	"python",
	"rasi",
	"regex",
	"rust",
	"sql",
	"ssh_config",
	"svelte",
	"swift",
	"templ",
	"toml",
	"tsx",
	"typescript",
	"typst",
	"vue",
	"yaml",
}

require("lazy").setup({

	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		branch = "main",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter").install(parsers)

			for _, parser in ipairs(parsers) do
				autocmd("FileType", {
					pattern = vim.treesitter.language.get_filetypes(parser),
					callback = function(args)
						vim.treesitter.start(args.buf)
					end,
				})
			end
		end,
	},

	{
		"hyperpuncher/tree-sitter-datastar",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},

	{
		"hyperpuncher/datastar-lsp",
		opts = {
			cmd = { "/home/igor/projects/datastar-lsp/target/release/datastar-lsp" },
		},
	},

	{ "nvim-tree/nvim-web-devicons", opts = {} },

	{
		"rose-pine/neovim",
		name = "rose-pine",
		opts = {
			styles = {
				italic = false,
				transparency = true,
			},
		},
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "mason-org/mason.nvim", opts = { max_concurrent_installers = 10 } },
			{ "mason-org/mason-lspconfig.nvim", opts = {} },
			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = vim.list_extend(vim.list_extend(vim.tbl_keys(servers), formatters), linters),
					auto_update = true,
				},
			},

			{
				"stevearc/conform.nvim",
				opts = {
					format_on_save = {
						timeout_ms = 1000,
						lsp_format = "fallback",
					},
					formatters = {
						caddy = {
							command = "caddy",
							args = { "fmt", "-" },
							stdin = true,
						},
						dsfmt = {
							command = "dsfmt",
							stdin = true,
						},
						oxfmt = {
							append_args = {
								"--config=" .. vim.fn.expand("~/.config/oxfmt/oxfmtrc.jsonc"),
							},
						},
						prettierd = {
							append_args = {
								"--config-precedence=file-override",
								"--print-width=90",
								"--use-tabs=true",
							},
						},
					},
					formatters_by_ft = {
						astro = { "prettierd" },
						c = { "clang-format" },
						caddy = { "caddy" },
						cpp = { "clang-format" },
						css = { "oxfmt" },
						go = { "gofumpt" },
						html = { "oxfmt" },
						http = { "kulala-fmt" },
						ino = { "clang-format" },
						javascript = { "oxfmt" },
						javascriptreact = { "oxfmt" },
						json = { "oxfmt" },
						jsonc = { "oxfmt" },
						lua = { "stylua" },
						markdown = { "oxfmt" },
						python = { "ruff_format", "ruff_organize_imports" },
						sql = { "pg_format" },
						svelte = { "prettierd" },
						swift = { "swiftformat" },
						templ = { "templ", "rustywind" },
						toml = { "oxfmt" },
						typescript = { "oxfmt" },
						typescriptreact = { "dsfmt", "oxfmt" },
						typst = { "typstyle" },
						vue = { "oxfmt" },
						xml = { "xmlformatter" },
						yaml = { "oxfmt" },
					},
				},
			},
		},
	},

	{
		"saghen/blink.cmp",
		version = "1.*",
		dependencies = {
			{ "rafamadriz/friendly-snippets" },
		},
		opts = {
			appearance = {
				nerd_font_variant = "normal",
			},

			completion = {
				menu = {
					draw = {
						components = {
							label = {
								width = { max = 30 },
							},
							label_description = {
								width = { max = 30 },
							},
						},
					},
				},

				documentation = {
					auto_show = true,
					auto_show_delay_ms = 200,
					window = {
						max_width = 50,
					},
				},
			},
		},
	},

	{
		"lewis6991/gitsigns.nvim",
		opts = {
			signs = {
				add = { text = "+" },
				change = { text = "~" },
				delete = { text = "-" },
				topdelete = { text = "‾" },
				changedelete = { text = "~" },
			},
		},
	},

	{ "nvim-mini/mini.surround", version = "*", opts = {} },

	{
		"rmagatti/auto-session",
		lazy = false,
		opts = {
			suppressed_dirs = { "/", "~/", "~/Desktop/", "~/Downloads" },
		},
	},

	{ "hiphish/rainbow-delimiters.nvim", submodules = false },

	{
		"codethread/qmk.nvim",
		lazy = true,
		config = function()
			local conf = {
				name = "ikiosuru",
				layout = {
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"x x x x x x _ x x x x x x",
					"_ _ _ x x x _ x x x _ _ _",
				},
				variant = "zmk",
			}
			require("qmk").setup(conf)
		end,
	},

	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			bigfile = {},
			indent = {
				animate = { enabled = false },
				filter = function(buf)
					return vim.g.snacks_indent ~= false
						and vim.b[buf].snacks_indent ~= false
						and vim.bo[buf].buftype == ""
						and vim.bo[buf].filetype ~= "markdown"
				end,
			},
			input = {},
			picker = {
				hidden = true,
				formatters = {
					file = {
						truncate = 100,
					},
				},
				layout = {
					preset = "dropdown",
				},
			},
			notifier = {},
			rename = {},
			zen = {
				toggles = {
					dim = false,
					git_signs = true,
				},
				show = {
					statusline = true,
				},
			},
		},
		keys = {
			{
				"<leader>:",
				function()
					Snacks.picker.command_history()
				end,
				desc = "Command History",
			},
			{
				"<leader>n",
				function()
					Snacks.picker.notifications()
				end,
				desc = "Notification History",
			},
			-- Grep
			{
				"<leader>sg",
				function()
					Snacks.picker.grep()
				end,
				desc = "Grep",
			},
			{
				"<leader>sw",
				function()
					Snacks.picker.grep_word()
				end,
				desc = "Visual selection or word",
				mode = { "n", "x" },
			},
			{
				"<leader>sC",
				function()
					Snacks.picker.commands()
				end,
				desc = "Commands",
			},
			{
				"<leader>sd",
				function()
					Snacks.picker.diagnostics()
				end,
				desc = "Diagnostics",
			},
			{
				"<leader>sD",
				function()
					Snacks.picker.diagnostics_buffer()
				end,
				desc = "Buffer Diagnostics",
			},
			{
				"<leader>sh",
				function()
					Snacks.picker.help()
				end,
				desc = "Help Pages",
			},
			{
				"<leader>si",
				function()
					Snacks.picker.icons()
				end,
				desc = "Icons",
			},
			{
				"<leader>sj",
				function()
					Snacks.picker.jumps()
				end,
				desc = "Jumps",
			},
			{
				"<leader>sk",
				function()
					Snacks.picker.keymaps()
				end,
				desc = "Keymaps",
			},
			{
				"<leader>sM",
				function()
					Snacks.picker.man()
				end,
				desc = "Man Pages",
			},
			{
				"<leader>sq",
				function()
					Snacks.picker.qflist()
				end,
				desc = "Quickfix List",
			},
			{
				"<leader>sr",
				function()
					Snacks.picker.resume()
				end,
				desc = "Resume",
			},
			{
				"<leader>su",
				function()
					Snacks.picker.undo()
				end,
				desc = "Undo History",
			},
			{
				"<leader>uC",
				function()
					Snacks.picker.colorschemes()
				end,
				desc = "Colorschemes",
			},
			-- LSP
			{
				"gd",
				function()
					Snacks.picker.lsp_definitions()
				end,
				desc = "Goto Definition",
			},
			{
				"gD",
				function()
					Snacks.picker.lsp_declarations()
				end,
				desc = "Goto Declaration",
			},
			{
				"gr",
				function()
					Snacks.picker.lsp_references()
				end,
				nowait = true,
				desc = "References",
			},
			{
				"gI",
				function()
					Snacks.picker.lsp_implementations()
				end,
				desc = "Goto Implementation",
			},
			{
				"gy",
				function()
					Snacks.picker.lsp_type_definitions()
				end,
				desc = "Goto T[y]pe Definition",
			},
			-- Other
			{
				"<leader>z",
				function()
					Snacks.zen()
				end,
				desc = "Toggle Zen Mode",
			},
			{
				"<leader>.",
				function()
					Snacks.scratch()
				end,
				desc = "Toggle Scratch Buffer",
			},
			{
				"<leader>S",
				function()
					Snacks.scratch.select()
				end,
				desc = "Select Scratch Buffer",
			},
			{
				"<leader>bd",
				function()
					Snacks.bufdelete()
				end,
				desc = "Delete Buffer",
			},
			{
				"<leader>cR",
				function()
					Snacks.rename.rename_file()
				end,
				desc = "Rename File",
			},
		},
	},

	{
		"supermaven-inc/supermaven-nvim",
		opts = {
			ignore_filetypes = { "bigfile", "fff_input", "minifiles" },
		},
	},

	{
		"nvim-mini/mini.statusline",
		version = false,
		config = function()
			local statusline = require("mini.statusline")
			statusline.section_location = function()
				return "%2l:%-2v"
			end
			statusline.section_filename = function()
				return vim.fn.expand("%:.")
			end
			statusline.section_fileinfo = function()
				local filetype = vim.bo.filetype
				local icon = require("nvim-web-devicons").get_icon(vim.fn.expand("%:t"), nil, { default = true })
				filetype = icon .. " " .. filetype
				return filetype
			end
			statusline.setup()
		end,
	},

	{
		"dmtrKovalenko/fff.nvim",
		build = function()
			require("fff.download").download_or_build_binary()
		end,
		lazy = false,
		opts = {
			prompt = "> ",
			layout = {
				height = 0.5,
				width = 0.7,
				preview_position = "top",
			},
			preview = {
				enabled = false,
			},
			hl = {
				border = "Comment",
			},
			keymaps = {
				cycle_grep_modes = "<C-m>",
			},
			grep = {
				trim_whitespace = true,
			},
		},
		keys = {
			{
				"<leader>p",
				function()
					require("fff").find_files()
				end,
				desc = "Open file picker",
			},
			{
				"<leader>/",
				function()
					require("fff").live_grep({
						grep = {
							modes = { "plain", "fuzzy" },
						},
					})
				end,
				desc = "Live fffuzy grep",
			},
		},
	},

	{
		"nvim-mini/mini.files",
		version = false,
		opts = {
			mappings = {
				go_in_plus = "<CR>",
			},
		},
	},
}, {
	ui = {
		border = "rounded",
	},
})

for name, config in pairs(servers) do
	vim.lsp.config(name, config)
end

map("n", "K", function()
	vim.lsp.buf.hover({
		max_width = 65,
	})
end)
map("n", "<leader>cp", vim.lsp.document_color.color_presentation)

map({ "n", "i" }, "<MiddleMouse>", "<Nop>")
map({ "n", "i", "v" }, "<RightMouse>", "<Nop>")
map({ "n", "i", "v" }, "<S-RightMouse>", "<Nop>")

map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

map({ "n", "v" }, "<Space>", "<Nop>")
map("n", "<C-a>", "ggVG")
map({ "i", "c" }, "<C-v>", "<C-R><C-R>+")

map("n", "<C-s>", ":w<CR>")
map({ "i", "v", "c" }, "<C-s>", "<Esc>:w<CR>")

map({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map("n", "-", function()
	MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
	MiniFiles.reveal_cwd()
end)

map("x", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("x", "K", ":m '<-2<CR>gv=gv", { silent = true })

map("n", "<leader>rn", vim.lsp.buf.rename, { desc = "Rename" })

map("n", "<C-f>", "<CMD>silent !tmux neww tmux-sessionizer<CR>")

map("n", "x", '"_x')
map("n", "X", '"_X')

vim.diagnostic.config({
	float = {
		max_width = 65,
	},
})

-- Format diagnostic message as markdown with code blocks
local function format_diagnostic_md(diagnostic)
	local msg = diagnostic.message
	local lang = vim.bo[0].filetype

	if lang and lang ~= "" then
		msg = msg:gsub("'({[^}]+})'", "\n\n```" .. lang .. "\n%1\n```\n\n")
		msg = msg:gsub("'([^']+)'", "`%1`")
	end

	return msg
end

-- Prettier diagnostic float
map("n", "<leader>d", function()
	-- Find diagnostic under cursor
	local cursor = vim.api.nvim_win_get_cursor(0)
	local line, col = cursor[1] - 1, cursor[2]
	local diagnostics = vim.diagnostic.get(0, { lnum = line })
	if #diagnostics == 0 then
		for i = line - 1, math.max(0, line - 3), -1 do
			diagnostics = vim.diagnostic.get(0, { lnum = i })
			if #diagnostics > 0 then
				break
			end
		end
	end
	local diag = nil
	for _, d in ipairs(diagnostics) do
		if col >= d.col and col <= d.end_col then
			diag = d
			break
		end
	end
	if not diag then
		diag = diagnostics[1]
	end
	if not diag then
		return
	end

	-- Format as markdown
	local md = format_diagnostic_md(diag)
	local lines = vim.split(md, "\n", { plain = true })

	-- Create buffer
	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
	vim.bo[buf].filetype = "markdown"

	-- Format with conform first
	require("conform").format({ bufnr = buf })

	lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	vim.api.nvim_buf_delete(buf, { force = true })

	local preview_buf, win = vim.lsp.util.open_floating_preview(lines, "markdown", {
		max_width = 50,
		max_height = 15,
		title = " " .. vim.diagnostic.severity[diag.severity] .. " ",
		anchor_bias = "below",
		close_events = {},
	})
	vim.wo[win].concealcursor = "n"
	vim.api.nvim_set_current_win(win)

	-- Close on q/Esc
	local close = function()
		vim.api.nvim_win_close(win, true)
	end
	vim.keymap.set("n", { "<Esc>", "q" }, close, { buffer = preview_buf, nowait = true })
end, { desc = "Show diagnostic" })

hl(0, "YankHighlight", { fg = "#131412", bg = "#E2E3E3" })
autocmd("TextYankPost", {
	callback = function()
		vim.hl.hl_op({ higroup = "YankHighlight" })
	end,
})

autocmd({ "BufRead", "BufNewFile", "BufEnter" }, {
	pattern = { "ikiosuru.py", ".env" },
	callback = function(args)
		vim.diagnostic.enable(false, args.buf)
	end,
})

autocmd("InsertLeave", {
	callback = function()
		vim.system({ "hyprctl", "switchxkblayout", "current", "0" })
	end,
})

autocmd("FileType", {
	callback = function()
		vim.opt.formatoptions:remove({ "c", "r", "o" })
	end,
})

local function set_picker_scrolloff()
	vim.wo.scrolloff = 0
	vim.wo.scrolloffpad = 0
end

local picker_scrolloff = vim.api.nvim_create_augroup("PickerScrolloff", { clear = true })
autocmd("FileType", {
	group = picker_scrolloff,
	pattern = { "fff_list", "fff_input", "fff_preview", "fff_file_info" },
	callback = set_picker_scrolloff,
})
autocmd("User", {
	group = picker_scrolloff,
	pattern = "MiniFilesWindowUpdate",
	callback = set_picker_scrolloff,
})

vim.filetype.add({
	filename = {
		Caddyfile = "caddy",
	},
})

vim.cmd.colorscheme("rose-pine")

vim.lsp.document_color.enable(true, nil, {
	style = "virtual",
})

require("vim._core.ui2").enable({})
