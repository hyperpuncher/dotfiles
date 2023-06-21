return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        opts = {
            flavour = "mocha",
            color_overrides = {
                mocha = {
                    base = "#191919",
                    mantle = "#202020",
                    crust = "#262626",
                }
            },
        },
    },

    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "catppuccin",
        },
    },
}
