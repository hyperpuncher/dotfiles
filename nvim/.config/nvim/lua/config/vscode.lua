local function augroup(name)
    return vim.api.nvim_create_augroup("lazyvim_" .. name, { clear = true })
end

vim.cmd [[highlight MyHighlight guifg=black guibg=white]]

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup("highlight_yank"),
    callback = function()
        vim.highlight.on_yank { higroup = "MyHighlight" }
    end,
})

-- undo/REDO via vscode
vim.keymap.set("n", "u", "<Cmd>call VSCodeNotify('undo')<CR>")
vim.keymap.set("n", "<C-r>", "<Cmd>call VSCodeNotify('redo')<CR>")

vim.opt.clipboard = 'unnamedplus'
