local async = require("nio.tests")
local neotest_bokehjs = require("neotest-bokehjs")
-- local nio = require("nio")

-- nio.run(function()
--     local positions = neotest_bokehjs.discover_positions("tests/data/test_file.ts"):to_list()
--     local output = vim.inspect(positions)
--     local file = io.open("results.txt", "w")
--     if file ~= nil then
--         file:write(output)
--         file:close()
--     end
-- end)

describe("discover_positions", function()
    async.it("discover_positions in test_file.ts", function()
        local positions = neotest_bokehjs.discover_positions("tests/data/test_file.ts"):to_list()
        local expected_positions = {
            {
                id = "tests/data/test_file.ts",
                name = "test_file.ts",
                path = "tests/data/test_file.ts",
                range = { 0, 0, 42, 0 },
                type = "file",
            },
            {
                {
                    id = 'tests/data/test_file.ts::"describe"',
                    name = '"describe"',
                    path = "tests/data/test_file.ts",
                    range = { 31, 21, 41, 1 },
                    type = "namespace",
                },
                {
                    {
                        id = 'tests/data/test_file.ts::"describe"::"it-1"',
                        name = '"it-1"',
                        path = "tests/data/test_file.ts",
                        range = { 32, 13, 34, 3 },
                        type = "test",
                    },
                },
                {
                    {
                        id = 'tests/data/test_file.ts::"describe"::"sub-describe"',
                        name = '"sub-describe"',
                        path = "tests/data/test_file.ts",
                        range = { 36, 27, 40, 3 },
                        type = "namespace",
                    },
                    {
                        {
                            id = 'tests/data/test_file.ts::"describe"::"sub-describe"::"it-2"',
                            name = '"it-2"',
                            path = "tests/data/test_file.ts",
                            range = { 37, 15, 39, 5 },
                            type = "test",
                        },
                    },
                },
            },
        }

        assert.are.same(positions, expected_positions)
    end)
end)
