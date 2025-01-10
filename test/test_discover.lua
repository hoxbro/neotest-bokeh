local neotest_bokeh = require("neotest-bokeh")
local nio = require("nio")

nio.run(function()
    local positions = neotest_bokeh.discover_positions("test/embed.ts")
    print(vim.inspect(positions)) -- Print positions for debugging
end)
