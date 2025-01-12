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
    headless = { log = vim.env.LAZY_INSTALL == "true" },
    lockfile = "tests/lazy-lock.json",
})
