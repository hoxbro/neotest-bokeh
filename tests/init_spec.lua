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

local root_dir = vim.uv.cwd() .. "/tests/data/bokehjs/"

describe("root_dir", function()
    async.it("check if root_dir is not set", function()
        assert.are_nil(neotest_bokehjs.root_dir)
        assert.are_nil(neotest_bokehjs.root("not relevant, is set with __call"))
    end)
    async.it("check if root_dir is set", function()
        neotest_bokehjs({ root_dir = root_dir })
        assert.are_equal(root_dir, neotest_bokehjs.root_dir)
        assert.are_equal(root_dir, neotest_bokehjs.root("not relevant, set with __call"))
    end)
end)

describe("filter_dir", function()
    local test_fn = function(x) return neotest_bokehjs.filter_dir("", x, "") end
    async.it("good 1", function() assert.are_true(test_fn("test")) end)
    async.it("good 2", function() assert.are_true(test_fn("test/unit/")) end)
    async.it("bad 1", function() assert.are_false(test_fn("tests")) end)
    async.it("bad 2", function() assert.are_false(test_fn("tests/unit/")) end)
    async.it("bad 3", function() assert.are_false(test_fn("example/test/")) end)
    async.it("bad 4", function() assert.are_false(test_fn("example/test/unit/")) end)
    async.it("bad 5", function() assert.are_false(test_fn("")) end)
end)

describe("is_test_file", function()
    local test_fn = function(x) return neotest_bokehjs.is_test_file(root_dir .. x) end
    async.it("good 1", function() assert.are_true(test_fn("/test/unit/index.ts")) end)
    async.it("good 2", function() assert.are_true(test_fn("/test/unit/sub/index.ts")) end)
    async.it("bad 1", function() assert.are_false(test_fn("/test/unit/index.d.ts")) end)
    async.it("bad 2", function() assert.are_false(test_fn("/test/unit/_index.ts")) end)
    async.it("bad 3", function() assert.are_false(test_fn("/test/unit/_index.ts")) end)
    async.it("bad 4", function() assert.are_false(test_fn("/test/unit/index.js")) end)
end)

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
                    id = "tests/data/test_file.ts::describe",
                    name = "describe",
                    path = "tests/data/test_file.ts",
                    range = { 31, 21, 41, 1 },
                    type = "namespace",
                },
                {
                    {
                        id = "tests/data/test_file.ts::describe::it-1",
                        name = "it-1",
                        path = "tests/data/test_file.ts",
                        range = { 32, 13, 34, 3 },
                        type = "test",
                    },
                },
                {
                    {
                        id = "tests/data/test_file.ts::describe::sub-describe",
                        name = "sub-describe",
                        path = "tests/data/test_file.ts",
                        range = { 36, 27, 40, 3 },
                        type = "namespace",
                    },
                    {
                        {
                            id = "tests/data/test_file.ts::describe::sub-describe::it-2",
                            name = "it-2",
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
