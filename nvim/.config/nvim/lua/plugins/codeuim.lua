return {
    {
        "Exafunction/codeium.vim",
        config = function()
            vim.keymap.set("i", "<C-l>", function()
                return vim.fn["codeium#Accept"]() .. "<Esc>"
            end, { expr = true })
        end,
    },
}
