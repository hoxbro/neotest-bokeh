load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

require("lazy.minit").busted({
    spec = {
        "nvim-lua/plenary.nvim",
        {
            "nvim-treesitter/nvim-treesitter",
            build = ":TSUpdate",
            main = "nvim-treesitter.configs",
            opts = { ensure_installed = { "typescript" } },
        },
        "nvim-neotest/nvim-nio",
        "nvim-neotest/neotest",
    },
})
