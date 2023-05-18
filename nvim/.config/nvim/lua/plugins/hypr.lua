return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {
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
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "black",
        "ruff",
        "ruff-lsp",
        "prettierd",
        "shellcheck",
        "typescript-language-server",
      },
    },
  },

  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function()
      local nls = require("null-ls")
      return {
        sources = {
          nls.builtins.formatting.stylua,
          nls.builtins.formatting.prettierd,
          nls.builtins.formatting.black,
          nls.builtins.formatting.shfmt,

          nls.builtins.diagnostics.shellcheck,
          nls.builtins.diagnostics.ruff,
        },
      }
    end,
  },

  {
    "Exafunction/codeium.vim",
    config = function()
      vim.keymap.set("i", "<C-g>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true })
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignore = false,
        },
      },
    },
  },

  {
    "theRealCarneiro/hyprland-vim-syntax",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = "hypr",
  },
}
