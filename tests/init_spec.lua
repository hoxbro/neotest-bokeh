local async = require("nio.tests")
local plugin = require("neotest-bokehjs")

local root_dir = vim.uv.cwd() .. "/tests/data/bokehjs/"

describe("root_dir", function()
    async.it("check if root_dir is not set", function()
        assert.are_nil(plugin.root_dir)
        assert.are_nil(plugin.root("not relevant, is set with __call"))
    end)
    async.it("check if root_dir is set", function()
        plugin({ root_dir = root_dir })
        assert.are_equal(root_dir, plugin.root_dir)
        assert.are_equal(root_dir, plugin.root("not relevant, set with __call"))
    end)
end)

describe("filter_dir", function()
    local test_fn = function(x) return plugin.filter_dir("", x, "") end
    async.it("good 1", function() assert.are_true(test_fn("test")) end)
    async.it("good 2", function() assert.are_true(test_fn("test/unit/")) end)
    async.it("bad 1", function() assert.are_false(test_fn("tests")) end)
    async.it("bad 2", function() assert.are_false(test_fn("tests/unit/")) end)
    async.it("bad 3", function() assert.are_false(test_fn("example/test/")) end)
    async.it("bad 4", function() assert.are_false(test_fn("example/test/unit/")) end)
    async.it("bad 5", function() assert.are_false(test_fn("")) end)
end)

describe("is_test_file", function()
    local test_fn = function(x) return plugin.is_test_file(root_dir .. x) end
    async.it("good 1", function() assert.are_true(test_fn("/test/unit/index.ts")) end)
    async.it("good 2", function() assert.are_true(test_fn("/test/unit/sub/index.ts")) end)
    async.it("bad 1", function() assert.are_false(test_fn("/test/unit/index.d.ts")) end)
    async.it("bad 2", function() assert.are_false(test_fn("/test/unit/_index.ts")) end)
    async.it("bad 3", function() assert.are_false(test_fn("/test/unit/_index.ts")) end)
    async.it("bad 4", function() assert.are_false(test_fn("/test/unit/index.js")) end)
end)

describe("discover_positions", function()
    async.it("discover_positions in test_file.ts", function()
        local positions = plugin.discover_positions("tests/data/test_file.ts"):to_list()
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

describe("build_spec", function()
    it("test-integrated", function()
        local case = {
            id = "tests/unit/test_file.ts::describe::it-1",
            name = "it-1",
            path = "tests/unit/test_file.ts",
            range = { 32, 13, 34, 3 },
            type = "test",
        }
        local tree = {}
        function tree:data() return case end
        local spec = plugin.build_spec({ tree = tree, strategy = "integrated" })

        assert(spec)
        assert.are_equal(spec.cwd, root_dir)
        assert.are_equal(spec.command, 'node make test:unit -k "it-1"')

        assert(spec.context)
        assert.are_equal(spec.context.position_id, "tests/unit/test_file.ts::describe::it-1")
        assert.are_equal(spec.context.strategy, "integrated")
    end)
    it("test-dap", function()
        local case = {
            id = "tests/unit/test_file.ts::describe::it-1",
            name = "it-1",
            path = "tests/unit/test_file.ts",
            range = { 32, 13, 34, 3 },
            type = "test",
        }
        local tree = {}
        function tree:data() return case end
        local spec = plugin.build_spec({ tree = tree, strategy = "dap" })

        assert(spec)
        local expected_strategy = {
            args = { "make", "test:unit", "-k", '"it-1"' },
            console = "integratedTerminal",
            cwd = root_dir,
            name = "Launch: BokehJS Tests",
            request = "launch",
            resolveSourceMapLocations = { root_dir, "!/node_modules/**" },
            runtimeExecutable = "node",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            sourceMaps = true,
            type = "pwa-node",
        }
        assert.same(spec.strategy, expected_strategy)

        assert(spec.context)
        assert.are_equal(spec.context.position_id, "tests/unit/test_file.ts::describe::it-1")
        assert.are_equal(spec.context.strategy, "dap")
    end)
    it("namespace-integrated", function()
        local case = {
            id = "tests/unit/test_file.ts::describe",
            name = "describe",
            path = "tests/unit/test_file.ts",
            range = { 31, 21, 41, 1 },
            type = "namespace",
        }
        local tree = {}
        function tree:data() return case end
        local spec = plugin.build_spec({ tree = tree, strategy = "integrated" })

        assert(spec)
        assert.are_equal(spec.cwd, root_dir)
        assert.are_equal(spec.command, 'node make test:unit -k "describe"')

        assert(spec.context)
        assert.are_equal(spec.context.position_id, "tests/unit/test_file.ts::describe")
        assert.are_equal(spec.context.strategy, "integrated")
    end)
    it("namespace-dap", function()
        local case = {
            id = "tests/unit/test_file.ts::describe",
            name = "describe",
            path = "tests/unit/test_file.ts",
            range = { 31, 21, 41, 1 },
            type = "namespace",
        }
        local tree = {}
        function tree:data() return case end
        local spec = plugin.build_spec({ tree = tree, strategy = "dap" })

        assert(spec)
        local expected_strategy = {
            args = { "make", "test:unit", "-k", '"describe"' },
            console = "integratedTerminal",
            cwd = root_dir,
            name = "Launch: BokehJS Tests",
            request = "launch",
            resolveSourceMapLocations = { root_dir, "!/node_modules/**" },
            runtimeExecutable = "node",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            sourceMaps = true,
            type = "pwa-node",
        }
        assert.same(spec.strategy, expected_strategy)

        assert(spec.context)
        assert.are_equal(spec.context.position_id, "tests/unit/test_file.ts::describe")
        assert.are_equal(spec.context.strategy, "dap")
    end)
    it("file-integrated", function() -- NOTE: Does not currently work when running code
        local case = {
            id = "tests/unit/test_file.ts",
            name = "test_file.ts",
            path = "tests/unit/test_file.ts",
            range = { 0, 0, 42, 0 },
            type = "file",
        }
        local tree = {}
        function tree:data() return case end
        local spec = plugin.build_spec({ tree = tree, strategy = "integrated" })

        assert(spec)
        assert.are_equal(spec.cwd, root_dir)
        assert.are_equal(spec.command, 'node make test:unit -k "test_file.ts"')

        assert(spec.context)
        assert.are_equal(spec.context.position_id, "tests/unit/test_file.ts")
        assert.are_equal(spec.context.strategy, "integrated")
    end)
    it("file-dap", function() -- NOTE: Does not currently work when running code
        local case = {
            id = "tests/unit/test_file.ts",
            name = "test_file.ts",
            path = "tests/unit/test_file.ts",
            range = { 0, 0, 42, 0 },
            type = "file",
        }
        local tree = {}
        function tree:data() return case end
        local spec = plugin.build_spec({ tree = tree, strategy = "dap" })

        assert(spec)
        local expected_strategy = {
            args = { "make", "test:unit", "-k", '"test_file.ts"' },
            console = "integratedTerminal",
            cwd = root_dir,
            name = "Launch: BokehJS Tests",
            request = "launch",
            resolveSourceMapLocations = { root_dir, "!/node_modules/**" },
            runtimeExecutable = "node",
            skipFiles = { "<node_internals>/**", "**/node_modules/**" },
            sourceMaps = true,
            type = "pwa-node",
        }
        assert.same(spec.strategy, expected_strategy)

        assert(spec.context)
        assert.are_equal(spec.context.position_id, "tests/unit/test_file.ts")
        assert.are_equal(spec.context.strategy, "dap")
    end)
end)
