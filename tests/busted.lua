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

local root = vim.fn.fnamemodify(vim.env.LAZY_STDPATH, ":p")
for _, name in ipairs({ "config", "data", "state", "cache" }) do
    vim.env[("XDG_%s_HOME"):format(name:upper())] = root .. "/" .. name
end

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
require("lazy.minit").busted.run()
