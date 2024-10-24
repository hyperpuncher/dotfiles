local opt = vim.opt
local cmd = vim.cmd
local map = vim.keymap.set
local hl = vim.api.nvim_set_hl
local autocmd = vim.api.nvim_create_autocmd

local bg_color = "#1A1A1A"

vim.g.mapleader = " "

opt.breakindent = true
opt.clipboard = "unnamedplus"
opt.completeopt = "menuone,noselect"
opt.expandtab = true
opt.hlsearch = false
opt.ignorecase = true
opt.inccommand = "split"
opt.mouse = "a"
opt.number = true
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true
opt.scrolloff = 15
opt.shiftwidth = 4
-- opt.showmode = false
opt.signcolumn = "yes"
opt.smartcase = true
opt.smartindent = true
opt.softtabstop = 4
opt.spell = false
opt.splitright = true
opt.swapfile = false
opt.tabstop = 4
opt.termguicolors = true
opt.timeoutlen = 500
opt.undofile = true
opt.updatetime = 200

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
	gopls = {},
	html = {},
	htmx = {},
	lua_ls = { Lua = { diagnostics = { globals = { "vim" } } } },
	marksman = {},
	nil_ls = {},
	openscad_lsp = {},
	pyright = {},
	ruff = {},
	rust_analyzer = {},
	svelte = {},
	tailwindcss = {},
	templ = {},
	ts_ls = {},
	yamlls = {},
}

local formatters = {
	"biome",
	"fixjson",
	"gofumpt",
	"nixpkgs-fmt",
	"prettierd",
	"rustywind",
	"shfmt",
	"stylua",
	"templ",
	"taplo",
}

local linters = {
	"golangci-lint",
	"jsonlint",
}

local ensure_installed = vim.tbl_keys(servers)
vim.list_extend(ensure_installed, formatters)
vim.list_extend(ensure_installed, linters)

require("lazy").setup({

	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				incremental_selection = {
					enable = true,
					keymaps = {
						node_incremental = "v",
						node_decremental = "V",
					},
				},
			})
		end,
		vim.filetype.add({
			pattern = { [".*/hyprland%.conf"] = "hyprlang" },
		}),
	},

	{
		"nvim-telescope/telescope.nvim",
		config = function()
			local telescope = require("telescope")
			local telescopeBuiltIn = require("telescope.builtin")
			local telescopeConfig = require("telescope.config")

			-- Clone the default Telescope configuration
			local vimgrep_arguments = { unpack(telescopeConfig.values.vimgrep_arguments) }

			table.insert(vimgrep_arguments, "--hidden")
			table.insert(vimgrep_arguments, "-u")
			table.insert(vimgrep_arguments, "--glob")
			table.insert(vimgrep_arguments, "!**/.git/*")
			table.insert(vimgrep_arguments, "--glob")
			table.insert(vimgrep_arguments, "!**/node_modules/*")

			telescope.setup({
				defaults = {
					vimgrep_arguments = vimgrep_arguments,
				},
				pickers = {
					find_files = {
						find_command = {
							"rg",
							"-u",
							"--files",
							"--hidden",
							"--glob",
							"!**/.git/*",
							"--glob",
							"!**/node_modules/*",
						},
						theme = "dropdown",
						previewer = false,
					},
					git_files = {
						theme = "dropdown",
						previewer = false,
					},
				},
			})

			-- We cache the results of "git rev-parse"
			-- Process creation is expensive in Windows, so this reduces latency
			local is_inside_work_tree = {}

			telescopeBuiltIn.project_files = function()
				local opts = {} -- define here if you want to define something

				local cwd = vim.fn.getcwd()
				if is_inside_work_tree[cwd] == nil then
					vim.fn.system("git rev-parse --is-inside-work-tree")
					is_inside_work_tree[cwd] = vim.v.shell_error == 0
				end

				if is_inside_work_tree[cwd] then
					require("telescope.builtin").git_files(opts)
				else
					require("telescope.builtin").find_files(opts)
				end
			end
		end,

		dependencies = {
			"nvim-lua/plenary.nvim",
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = "make",
				cond = function()
					return vim.fn.executable("make") == 1
				end,
			},
		},
	},

	{
		"stevearc/oil.nvim",
		opts = {
			use_default_keymaps = false,
			keymaps = {
				["<CR>"] = "actions.select",
				["-"] = "actions.parent",
				["<C-c>"] = "actions.close",
			},
			view_options = {
				show_hidden = true,
			},
		},
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	{
		"Mofiqul/dracula.nvim",
		opts = {
			colors = {
				-- bg = bg_color,
				-- black = "white",
				-- menu = bg_color,
				black = "None",
				bg = "None",
				menu = "None",
			},
			italic_comment = true,
			transparent_bg = true,
		},
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = { ui = { border = "rounded" } },
			},

			{
				"williamboman/mason-lspconfig.nvim",
				config = function()
					local group = vim.api.nvim_create_augroup("__env", { clear = true })
					vim.api.nvim_create_autocmd("BufEnter", {
						pattern = ".env",
						group = group,
						callback = function(args)
							vim.diagnostic.disable(args.buf)
						end,
					})
				end,
			},

			{
				"WhoIsSethDaniel/mason-tool-installer.nvim",
				opts = {
					ensure_installed = ensure_installed,
					auto_update = true,
				},
			},

			{
				"j-hui/fidget.nvim",
				opts = {
					notification = {
						window = {
							winblend = 0,
							border = "rounded",
						},
					},
				},
			},

			{
				"stevearc/conform.nvim",
				opts = {
					format_on_save = {
						timeout_ms = 500,
						lsp_fallback = true,
					},
					notify_on_error = false,
					formatters_by_ft = {
						astro = { "prettierd", "rustywind" },
						c = { "clang-format" },
						cpp = { "clang-format" },
						css = { "biome" },
						dart = { "dart_format" },
						go = { "gofumpt" },
						ino = { "clang-format" },
						javascript = { "biome", "rustywind" },
						json = { "fixjson", "biome" },
						lua = { "stylua" },
						markdown = { "prettierd" },
						nix = { "nixpkgs_fmt" },
						python = { "ruff_format", "ruff_organize_imports" },
						sh = { "shfmt" },
						sql = { "pg_format" },
						svelte = { "prettierd", "rustywind" },
						templ = { "templ", "rustywind" },
						toml = { "taplo" },
						yaml = { "prettierd" },
					},
				},
			},

			{
				"mfussenegger/nvim-lint",
				config = function()
					local lint = require("lint")
					lint.linters_by_ft = {
						go = { "golangcilint" },
						json = { "jsonlint" },
					}

					-- Create autocommand which carries out the actual linting
					-- on the specified events.
					local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
					vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
						group = lint_augroup,
						callback = function()
							require("lint").try_lint()
						end,
					})
				end,
			},
		},
	},

	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "│",
			},
			scope = { enabled = false },
			exclude = {
				filetypes = {
					"help",
					"alpha",
					"dashboard",
					"neo-tree",
					"Trouble",
					"trouble",
					"lazy",
					"mason",
					"notify",
					"toggleterm",
					"lazyterm",
				},
			},
		},
		dependencies = {
			{
				"echasnovski/mini.indentscope",
				opts = {
					symbol = "│",
					draw = {
						delay = 0,
						animation = function()
							return 0
						end,
					},
					options = {
						border = "top",
					},
				},
			},
		},
	},

	{
		"hrsh7th/nvim-cmp",
		dependencies = {
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-cmdline",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-nvim-lua",
			"hrsh7th/cmp-path",
			"onsails/lspkind.nvim",
			"L3MON4D3/LuaSnip",
			"saadparwaiz1/cmp_luasnip",
			"rafamadriz/friendly-snippets",
			"roobert/tailwindcss-colorizer-cmp.nvim",
		},
	},

	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup({
				pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
				toggler = { line = "<C-/>" },
			})
		end,
		dependencies = {
			"JoosepAlviste/nvim-ts-context-commentstring",
			opts = {
				languages = {
					templ = {
						__default = "// %s",
						component_declaration = "<!-- %s -->",
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

	{
		"NvChad/nvim-colorizer.lua",
		opts = {
			user_default_options = {
				tailwind = true,
			},
		},
	},

	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {},
	},

	{ "rmagatti/auto-session", opts = {} },

	{ "smjonas/inc-rename.nvim", opts = {} },

	{ "hiphish/rainbow-delimiters.nvim" },

	{
		"Exafunction/codeium.vim",
		event = "BufEnter",
		config = function()
			vim.g.codeium_enabled = false
			-- vim.g.codeium_disable_bindings = 1
			-- map("i", "<C-'>", function()
			-- 	return vim.fn["codeium#Accept"]()
			-- end, { expr = true, silent = true })
		end,
	},

	{
		"folke/zen-mode.nvim",
		opts = {
			window = { backdrop = 1 },
		},
	},

	{
		"ellisonleao/glow.nvim",
		cmd = "Glow",
		opts = {
			border = "rounded",
			width_ratio = 0.8,
			height_ratio = 0.8,
		},
	},

	{
		"folke/trouble.nvim",
		keys = {
			{
				"<leader>d",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>q",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
		opts = {},
	},

	{ "Darazaki/indent-o-matic", opts = {} },

	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
	},

	{
		"codethread/qmk.nvim",
		config = function()
			---@type qmk.UserConfig
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
}, {
	ui = {
		border = "rounded",
	},
})

cmd.colorscheme("dracula")

autocmd("FileType", {
	command = "set formatoptions-=cro",
})

local telescope_fn = require("telescope.builtin")

map("n", "<leader>f", telescope_fn.find_files)
map("n", "<leader>g", telescope_fn.project_files)
map("n", "<leader>w", telescope_fn.live_grep)
map("n", "<leader>h", telescope_fn.help_tags)
map("n", "<leader>cw", function()
	local word = vim.fn.expand("<cword>")
	telescope_fn.grep_string({ search = word })
end)
map("n", "<leader>cW", function()
	local word = vim.fn.expand("<cWORD>")
	telescope_fn.grep_string({ search = word })
end)

local harpoon = require("harpoon")

map("n", "<leader>a", function()
	harpoon:list():add()
end)
map("n", "<leader>b", function()
	harpoon.ui:toggle_quick_menu(harpoon:list())
end)
map("n", "<leader>j", function()
	harpoon:list():select(1)
end)
map("n", "<leader>k", function()
	harpoon:list():select(2)
end)
map("n", "<leader>l", function()
	harpoon:list():select(3)
end)
map("n", "<leader>;", function()
	harpoon:list():select(4)
end)
map("n", "H", function()
	harpoon:list():prev()
end)
map("n", "L", function()
	harpoon:list():next()
end)

map({ "n", "i" }, "<MiddleMouse>", "<Nop>")
map({ "n", "i", "v" }, "<RightMouse>", "<Nop>")
map({ "n", "i", "v" }, "<S-RightMouse>", "<Nop>")

map("n", "<C-h>", "<C-w><C-h>")
map("n", "<C-j>", "<C-w><C-j>")
map("n", "<C-k>", "<C-w><C-k>")
map("n", "<C-l>", "<C-w><C-l>")

map("n", "<C-d>", "0<C-d>zz")
map("n", "<C-u>", "0<C-u>zz")
map("n", "G", "0Gzz")
map("n", "N", "Nzz")
map("n", "n", "nzz")
map({ "n", "v" }, "<Space>", "<Nop>")
map("n", "<C-a>", "ggVG")
map({ "i", "c" }, "<C-v>", "<C-R><C-R>+")

map("n", "<C-s>", ":w<CR>")
map({ "i", "v" }, "<C-s>", "<Esc>:w<CR>")

map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

map("n", "-", "<CMD>Oil<CR>")

map("v", "J", ":m '>+1<CR>gv=gv", { silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true })

map("n", "<leader>x", ":bd<CR>")

map("n", "<leader>rn", ":IncRename ")

-- Increase and decrease ints
map("n", "<C-S-a>", "<C-a>")
map("n", "<C-S-x>", "<C-x>")

-- Diagnostic keymaps
map("n", "[d", vim.diagnostic.goto_prev)
map("n", "]d", vim.diagnostic.goto_next)
map("n", "<leader>e", vim.diagnostic.open_float)

map("n", "<leader>z", ":ZenMode<CR>", { silent = true })

--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
	local nmap = function(keys, func, desc)
		if desc then
			desc = "LSP: " .. desc
		end

		map("n", keys, func, { buffer = bufnr, desc = desc })
	end

	nmap("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")

	nmap("gd", telescope_fn.lsp_definitions, "[G]oto [D]efinition")
	nmap("gr", telescope_fn.lsp_references, "[G]oto [R]eferences")
	nmap("gI", telescope_fn.lsp_implementations, "[G]oto [I]mplementation")
	nmap("<leader>D", telescope_fn.lsp_type_definitions, "Type [D]efinition")

	nmap("K", vim.lsp.buf.hover, "Hover Documentation")
end

hl(0, "YankHighlight", { fg = "black", bg = "white" })
local highlight_group = vim.api.nvim_create_augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
	callback = function()
		vim.highlight.on_yank({ higroup = "YankHighlight" })
	end,
	group = highlight_group,
	pattern = "*",
})

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

require("mason-lspconfig").setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = servers[server_name],
			filetypes = (servers[server_name] or {}).filetypes,
		})
	end,
})

-- [[ Configure nvim-cmp ]]
local cmp = require("cmp")
local luasnip = require("luasnip")
local lspkind = require("lspkind")
require("luasnip.loaders.from_vscode").lazy_load()
luasnip.config.setup({})

cmp.setup({
	formatting = {
		format = lspkind.cmp_format({
			maxwidth = 50,
			ellipsis_char = "...",
		}),
	},
	view = {
		entries = { name = "custom", selection_order = "near_cursor" },
	},
	window = {
		completion = cmp.config.window.bordered({
			border = "rounded",
			winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
		}),
		documentation = cmp.config.window.bordered({
			border = "rounded",
		}),
	},
	snippet = {
		expand = function(args)
			luasnip.lsp_expand(args.body)
		end,
	},
	completion = {
		completeopt = "menu,menuone,noinsert",
	},
	mapping = cmp.mapping.preset.insert({
		["<C-y>"] = cmp.mapping.confirm(),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
		{ name = "path" },
		{ name = "luasnip" },
		{ name = "buffer" },
	},
	-- experimental = {
	-- 	ghost_text = true,
	-- },
})

-- `:` cmdline setup.
cmp.setup.cmdline(":", {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = "path" },
	}, {
		{ name = "cmdline", keyword_length = 3 },
	}),
})

cmp.config.formatting = {
	format = require("tailwindcss-colorizer-cmp").formatter,
}

vim.filetype.add({ extension = { templ = "templ" } })
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "rounded" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = "rounded" })
vim.diagnostic.config({ float = { border = "rounded" } })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
	pattern = "ikiosuru.py",
	callback = function()
		vim.diagnostic.disable()
	end,
})
