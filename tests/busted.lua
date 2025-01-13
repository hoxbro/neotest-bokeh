local lazypath = vim.env.LAZY_STDPATH
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        "--depth=1",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

local opts = require("lazy.minit").busted.setup({
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
    lockfile = "tests/lazy-lock.json",
})

vim.o.loadplugins = true
require("lazy").setup(opts)

if _G.arg[1] == "--install" then
    require("lazy").restore():wait()
else
    require("lazy.minit").busted.run()
end
