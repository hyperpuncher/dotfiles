if vim.g.vscode then
else
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
    opt.mouse = "a"
    opt.number = true
    opt.relativenumber = true
    opt.scrolloff = 15
    opt.shiftwidth = 4
    opt.showmode = false
    opt.signcolumn = "yes"
    opt.smartcase = true
    opt.smartindent = true
    opt.softtabstop = 4
    opt.spell = false
    opt.swapfile = false
    opt.tabstop = 4
    opt.termguicolors = true
    opt.timeoutlen = 500
    opt.undofile = true
    opt.updatetime = 200
    opt.splitright = true

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
        gopls = {},
        lua_ls = {
            Lua = {
                diagnostics = {
                    globals = {
                        "vim",
                    },
                },
            },
        },
        rnix = {},
        tsserver = {},
        marksman = {},
        pyright = {},
        rust_analyzer = {},
        svelte = {},
        tailwindcss = {},
    }

    require("lazy").setup({

        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            config = function()
                require("nvim-treesitter.configs").setup({
                    ensure_installed = {
                        "astro",
                        "bash",
                        "c",
                        "cpp",
                        "css",
                        "go",
                        "html",
                        "javascript",
                        "json",
                        "jsonc",
                        "lua",
                        "markdown",
                        "nix",
                        "python",
                        "rust",
                        "sql",
                        "svelte",
                        "toml",
                        "typescript",
                        "yaml",
                    },
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
        },

        {
            "nvim-telescope/telescope.nvim",
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
            config = function()
                require("telescope").setup({
                    pickers = {
                        buffers = {
                            mappings = {
                                i = {
                                    ["<c-d>"] = "delete_buffer",
                                },
                            },
                        },
                    },
                })
            end,
        },

        {
            "stevearc/oil.nvim",
            opts = {
                view_options = {
                    show_hidden = true,
                },
                use_default_keymaps = false,
                keymaps = {
                    ["<CR>"] = "actions.select",
                    ["-"] = "actions.parent",
                    ["<C-c>"] = "actions.close",
                },
            },
            dependencies = { "nvim-tree/nvim-web-devicons" },
        },

        {
            "nvim-lualine/lualine.nvim",
            opts = {
                options = {
                    component_separators = "",
                    section_separators = "",
                    globalstatus = true,
                    disabled_filetypes = { statusline = { "dashboard", "alpha", "starter", "veil" } },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = {},
                    lualine_c = {
                        {
                            "buffers",
                            mode = 2,
                            buffers_color = {
                                active = { bg = bg_color },
                            },
                            filetype_names = {
                                lazy = "lazy ",
                                oil = "oil ",
                                lspinfo = "lsp ",
                            },
                            symbols = {
                                modified = " ●",
                                alternate_file = "",
                                directory = "",
                            },
                        },
                    },
                    lualine_x = {},
                    lualine_y = {},
                    lualine_z = { "location" },
                },
            },
            dependencies = { "nvim-tree/nvim-web-devicons" },
        },

        {
            "Mofiqul/dracula.nvim",
            opts = {
                colors = {
                    bg = bg_color,
                    menu = bg_color,
                },
                italic_comment = true,
            },
        },

        {
            "neovim/nvim-lspconfig",
            dependencies = {
                {
                    "williamboman/mason.nvim",
                    opts = {
                        ui = {
                            border = "single",
                        },
                    },
                },
                {
                    "williamboman/mason-lspconfig.nvim",
                    opts = { ensure_installed = vim.tbl_keys(servers) },
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
        },

        {
            "nvimtools/none-ls.nvim",
            config = function()
                local null_ls = require("null-ls")
                local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
                local fmt = null_ls.builtins.formatting
                local lint = null_ls.builtins.diagnostics

                null_ls.setup({
                    sources = {
                        fmt.stylua,
                        fmt.ruff,
                        fmt.gofumpt,
                        fmt.shfmt,
                        fmt.nixpkgs_fmt,

                        lint.ruff,
                        lint.golangci_lint,
                        lint.shellcheck,
                        lint.staticcheck,
                    },

                    on_attach = function(client, bufnr)
                        if client.supports_method("textDocument/formatting") then
                            vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                            autocmd("BufWritePre", {
                                group = augroup,
                                buffer = bufnr,
                                callback = function()
                                    vim.lsp.buf.format({ async = false })
                                end,
                            })
                        end
                    end,
                })
            end,
        },

        { "mbbill/undotree" },

        {
            -- Autocompletion
            "hrsh7th/nvim-cmp",
            dependencies = {
                "hrsh7th/cmp-buffer",
                "hrsh7th/cmp-cmdline",
                "hrsh7th/cmp-path",
                "hrsh7th/cmp-nvim-lua",

                -- Snippet Engine & its associated nvim-cmp source
                "L3MON4D3/LuaSnip",
                "saadparwaiz1/cmp_luasnip",

                -- Adds LSP completion capabilities
                "hrsh7th/cmp-nvim-lsp",
                "hrsh7th/cmp-path",

                -- Adds a number of user-friendly snippets
                "rafamadriz/friendly-snippets",

                -- Icon support
                "onsails/lspkind.nvim",

                -- Tailwind
                "roobert/tailwindcss-colorizer-cmp.nvim",
            },
        },

        {
            "echasnovski/mini.comment",
            version = false,
            opts = {
                options = {
                    ignore_blank_line = true,
                },
                mappings = {
                    comment_line = "<C-/>",
                    comment_visual = "<C-/>",
                },
            },
        },

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
            },
        },

        {
            "lewis6991/gitsigns.nvim",
            opts = {
                signs = {
                    add = { text = "+" },
                    change = { text = "~" },
                    delete = { text = "_" },
                    topdelete = { text = "‾" },
                    changedelete = { text = "~" },
                },
            },
        },

        {
            "goolord/alpha-nvim",
            dependencies = { "nvim-tree/nvim-web-devicons" },
            config = function()
                require("alpha").setup(require("alpha.themes.startify").config)
            end,
        },

        {
            "rmagatti/auto-session",
            opts = {},
        },

        {
            "NvChad/nvim-colorizer.lua",
            opts = {
                user_default_options = {
                    tailwind = true,
                },
            },
        },

        { "smjonas/inc-rename.nvim", opts = {} },

        {
            "kylechui/nvim-surround",
            version = "*", -- Use for stability; omit to use `main` branch for the latest features
            event = "VeryLazy",
            opts = {},
        },

        {
            "windwp/nvim-autopairs",
            event = "InsertEnter",
            opts = {
                map_bs = false,
            },
        },
    }, {
        ui = {
            border = "single",
        },
    })

    cmd.colorscheme("dracula")

    autocmd("FileType", {
        command = "set formatoptions-=cro",
    })

    local telescope_fn = require("telescope.builtin")

    map("n", "<leader>f", telescope_fn.find_files)
    map("n", "<leader>g", telescope_fn.git_files)
    map("n", "<leader>w", telescope_fn.live_grep)
    map("n", "<leader>r", telescope_fn.oldfiles)
    map("n", "<leader><space>", telescope_fn.buffers)
    map("n", "<leader>cw", function()
        local word = vim.fn.expand("<cword>")
        telescope_fn.grep_string({ search = word })
    end)
    map("n", "<leader>cW", function()
        local word = vim.fn.expand("<cWORD>")
        telescope_fn.grep_string({ search = word })
    end)

    map("n", "<MiddleMouse>", "<Nop>")
    map("i", "<MiddleMouse>", "<Nop>")
    map({ "n", "i", "v" }, "<RightMouse>", "<Nop>")
    map({ "n", "i", "v" }, "<S-RightMouse>", "<Nop>")

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

    map("n", ";q", ":qa!<CR>")

    map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
    map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

    map("n", "-", "<CMD>Oil<CR>")

    map("n", "<leader>u", ":UndotreeShow<CR><C-w>h", { silent = true })

    map("v", "<A-j>", ":m '>+1<CR>gv=gv", { silent = true })
    map("v", "<A-k>", ":m '<-2<CR>gv=gv", { silent = true })

    map("n", "<leader>l", ":Lazy<CR>", { silent = true })

    map("n", "<S-l>", ":bnext<CR>", { silent = true })
    map("n", "<S-h>", ":bprevious<CR>", { silent = true })

    map("n", "<leader>rn", ":IncRename ")

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
        nmap("<leader>ds", telescope_fn.lsp_document_symbols, "[D]ocument [S]ymbols")
        nmap("<leader>ws", telescope_fn.lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")

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
                mode = "symbol",
                maxwidth = 50,
                ellipsis_char = "...",
            }),
        },
        view = {
            entries = { name = "custom", selection_order = "near_cursor" },
        },
        window = {
            completion = cmp.config.window.bordered({
                border = "single",
                winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
            }),
            documentation = cmp.config.window.bordered({
                border = "single",
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
            ["<CR>"] = cmp.mapping.confirm(),
        }),
        sources = {
            { name = "nvim_lsp" },
            { name = "nvim_lua" },
            { name = "path" },
            { name = "luasnip" },
            { name = "buffer" },
        },
    })

    -- `:` cmdline setup.
    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        }),
    })

    cmp.config.formatting = {
        format = require("tailwindcss-colorizer-cmp").formatter,
    }

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
    vim.lsp.handlers["textDocument/signatureHelp"] =
        vim.lsp.with(vim.lsp.handlers.signature_help, { border = "single" })
    vim.diagnostic.config({ float = { border = "single" } })
end
