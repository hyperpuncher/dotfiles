return {
    {
        "folke/which-key.nvim",
        init = function()
            vim.o.timeout = true
            vim.o.timeoutlen = 1500
        end,
    },

    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                pyright = {
                    capabilities = (function()
                        local capabilities = vim.lsp.protocol.make_client_capabilities()
                        capabilities.textDocument.publishDiagnostics.tagSupport.valueSet = { 2 }
                        return capabilities
                    end)(),
                    settings = {
                        python = {
                            analysis = {
                                typeCheckingMode = "off",
                            },
                        },
                    },
                },
            },
        },
    },

    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            ensure_installed = {
                "astro",
                "css",
                "dockerfile",
                "jsonc",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "regex",
                "svelte",
                "typescript",
                "yaml",
            },
        },
    },

    {
        "williamboman/mason.nvim",
        opts = {
            ensure_installed = {
                "astro-language-server",
                "black",
                "eslint_d",
                "isort",
                "marksman",
                "prettier",
                "prettierd",
                "pyright",
                "ruff",
                "rustywind",
                "shellcheck",
                "shfmt",
                "svelte-language-server",
                "tailwindcss-language-server",
            },
        },
    },

    {
        "jose-elias-alvarez/null-ls.nvim",
        opts = function()
            local nls = require("null-ls")
            return {
                sources = {
                    nls.builtins.diagnostics.eslint_d,
                    nls.builtins.formatting.prettierd,
                    nls.builtins.formatting.prettier.with({
                        filetypes = { "svelte" },
                        extra_filetypes = { "svelte" },
                    }),
                    nls.builtins.formatting.rustywind,

                    nls.builtins.diagnostics.shellcheck,

                    -- python
                    nls.builtins.diagnostics.ruff,
                    nls.builtins.formatting.black,
                    nls.builtins.formatting.isort.with({
                        extra_args = { "--profile", "black" },
                    }),

                    -- shell
                    nls.builtins.formatting.shfmt,
                },
            }
        end,
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        opts = {
            filesystem = {
                filtered_items = {
                    hide_dotfiles = false,
                    hide_gitignored = false,
                },
            },
        },
    },

    {
        "nvim-telescope/telescope.nvim",
        opts = {
            pickers = {
                find_files = {
                    find_command = {
                        "fd",
                        "-E",
                        "Desktop",
                        "-t",
                        "f",
                        "-t",
                        "l",
                    },
                },
            },
        },
    },

    {
        "nvim-lualine/lualine.nvim",
        opts = {
            options = {
                component_separators = { left = "|", right = "|" },
                section_separators = { left = "", right = "" },
            },
            sections = {
                lualine_c = {
                    {
                        "filetype",
                        icon_only = true,
                        separator = "",
                        padding = {
                            left = 1,
                            right = 0,
                        },
                    },
                    { "filename", path = 1, symbols = { modified = "  ", readonly = "", unnamed = "" } },
                },
                lualine_y = {},
                lualine_z = {
                    {
                        "progress",
                        separator = " ",
                        padding = { left = 1, right = 0 },
                    },
                    { "location", padding = { left = 0, right = 1 } },
                },
            },
        },
    },

    {
        "echasnovski/mini.comment",
        opts = {
            options = {
                ignore_blank_line = true,
            },
        },
    },

    {
        "rcarriga/nvim-notify",
        opts = {
            timeout = 0,
        },
    },

    { "echasnovski/mini.pairs", enabled = false },

    {
        "iamcco/markdown-preview.nvim",
        ft = "markdown",
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        init = function()
            -- vim.g.mkdp_auto_start = 1
            vim.g.mkdp_auto_close = 0
        end,
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
        "hrsh7th/nvim-cmp",
        dependencies = {
            { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
        },
        opts = function(_, opts)
            opts.experimental = {
                ghost_text = false,
            }
            -- original LazyVim kind icon formatter
            local format_kinds = opts.formatting.format
            opts.formatting.format = function(entry, item)
                format_kinds(entry, item) -- add icons
                return require("tailwindcss-colorizer-cmp").formatter(entry, item)
            end
        end,
    },

    {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = function()
            require("chatgpt").setup()
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    },

    {
        "theRealCarneiro/hyprland-vim-syntax",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        ft = "hypr",
    },

    {
        "Fymyte/rasi.vim",
        ft = "rasi",
    },
}
