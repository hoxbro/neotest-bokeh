# neotest-bokehjs

[Neotest](https://github.com/nvim-neotest/neotest) adapter for [BokehJS](https://github.com/bokeh/bokeh)

https://github.com/user-attachments/assets/5c56ac60-b6cb-4b8e-afc4-b315b9dab219

## Installation

Requires [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) and the TypeScript parser.

Installation with [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/nvim-nio",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "hoxbro/neotest-bokehjs",
  },
    config = function()
        require("neotest").setup({
            adapters = { require("neotest-bokehjs") },
        })
    end,
}
```

The plugin will automatically detect the BokehJS root directory, where all commands are run from.

This plugin requires a working BokehJS setup, see [the official documentation](https://docs.bokeh.org/en/latest/docs/dev_guide/bokehjs.html#building-bokehjs).

## Debugging Tests

The DAP-adapter used for debugging is the `js-debug-adapter`; this can be installed via [Mason](https://github.com/williamboman/mason.nvim).
My adapter dap-configuration looks like this. For more information see [nvim-dap](https://github.com/mfussenegger/nvim-dap/wiki/Debug-Adapter-installation),

```lua
local adapters = {
    ["pwa-node"] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = { command = vim.fn.exepath("js-debug-adapter"), args = { "${port}" } },
    },
}
```

## Limitations

There currently are the following limitations. It is likely that these require changes in BokehJS itself.

- Debugging does not work inside tests, likely because of SourceMap configurations.
- Running test in the namespace will flag all as passed/failed.
- Running a file does not work.

## Acknowledgments

- [rouge8/neotest-rust](https://github.com/rouge8/neotest-rust), used as a reference for writing this plugin.
