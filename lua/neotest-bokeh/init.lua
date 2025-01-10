local neotest_bokeh = {}

---@class neotest-bokeh.Adapter
---@field name string
neotest_bokeh.Adapter = {}

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function neotest_bokeh.Adapter.root(dir)
    return "/home/shh/projects/bokeh/bokehjs" -- TODO: Hardcoded
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function neotest_bokeh.Adapter.filter_dir(name, rel_path, root)
    return true -- TODO: Hardcoded
end

---@async
---@param file_path string
---@return boolean
function neotest_bokeh.Adapter.is_test_file(file_path)
    return true -- TODO: Hardcoded
end

---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function neotest_bokeh.Adapter.discover_positions(file_path)
    local lib = require("neotest.lib")
    local query = [[
    ;; Match describe blocks
    ((call_expression
        function: (identifier) @func_name (#eq? @func_name "describe")
        arguments: (arguments
          (_) @namespace.name
          (arrow_function) @namespace.definition
        )
    ))

    ;; Match it blocks
    ((call_expression
        function: (identifier) @func_name (#eq? @func_name "it")
        arguments: (arguments
          (_) @test.name
          (arrow_function) @test.definition
        )
    ))
    ]]

    ---@diagnostic disable-next-line: missing-fields
    return lib.treesitter.parse_positions(file_path, query, { nested_namespaces = true })
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function neotest_bokeh.Adapter.build_spec(args) end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function neotest_bokeh.Adapter.results(spec, result, tree) end
