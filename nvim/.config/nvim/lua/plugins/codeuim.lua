return {
    {
        "Exafunction/codeium.vim",
        enabled = false,
        config = function()
            vim.keymap.set("i", "<C-l>", function()
                return vim.fn["codeium#Accept"]() .. "<Esc>"
            end, { expr = true })
        end,
    },
}
