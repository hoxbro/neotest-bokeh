---@class neotest-bokeh.Adapter
---@field name string
local adapter = { name = "neotest-bokeh" }

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function adapter.root(dir)
    -- return "/home/shh/projects/bokeh/bokehjs" -- TODO: Hardcoded
    return "/home/shh/projects/neotest-bokeh" -- TODO: Hardcoded
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function adapter.filter_dir(name, rel_path, root)
    return true -- TODO: Hardcoded
end

---@async
---@param file_path string
---@return boolean
function adapter.is_test_file(file_path)
    return file_path:match("%.ts$") ~= nil
end

---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function adapter.discover_positions(file_path)
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
function adapter.build_spec(args)
    return nil -- TODO: Hardcoded
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function adapter.results(spec, result, tree) end

setmetatable(adapter, {
    __call = function(_, opts)
        -- if is_callable(opts.args) then
        --     get_args = opts.args
        -- elseif opts.args then
        --     get_args = function() return opts.args end
        -- end
        -- if is_callable(opts.dap_adapter) then
        --     get_dap_adapter = opts.dap_adapter
        -- elseif opts.dap_adapter then
        --     get_dap_adapter = function() return opts.dap_adapter end
        -- end
        return adapter
    end,
})

return adapter
