local present, null_ls = pcall(require, "null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

if not present then
  return
end

local format = null_ls.builtins.formatting
local lint = null_ls.builtins.diagnostics

local sources = {

  format.prettier,
  format.stylua,
  format.clang_format,
  format.black,

  lint.shellcheck,
  lint.ruff,
}

null_ls.setup {
  debug = true,
  sources = sources,
  on_attach = function(client, bufnr)
      if client.supports_method("textDocument/formatting") then
          vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
          vim.api.nvim_create_autocmd("BufWritePre", {
              group = augroup,
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format({ bufnr = bufnr })
              end,
          })
      end
  end,
}
