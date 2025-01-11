local neotest_bokehjs = require("neotest-bokehjs")
local nio = require("nio")

nio.run(function()
    local positions = neotest_bokehjs.discover_positions("test/embed.ts")
    print(vim.inspect(positions)) -- Print positions for debugging
end)
