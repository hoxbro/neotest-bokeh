local Path = require("plenary.path")
local lib = require("neotest.lib")

local root_dir
local test_types = { "integration", "unit", "defaults" }

local get_test_type = function(path)
    local paths = (type(path) == "string" and vim.split(path, Path.path.sep)) or path
    local matches = vim.tbl_filter(function(val) return vim.tbl_contains(paths, val) end, test_types)
    return matches[1]
end

---@class neotest-bokeh.Adapter
---@field name string
local adapter = { name = "neotest-bokehjs" }

---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function adapter.root(dir)
    if root_dir == nil then
        local root_parent = lib.files.match_root_pattern("bokehjs")(dir)
        if root_parent ~= nil then root_dir = root_parent .. "/bokehjs" end
    end
    return root_dir
end

---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function adapter.filter_dir(name, rel_path, root)
    local paths = vim.split(rel_path, Path.path.sep)
    return paths[1] == "test" and (paths[2] == nil or vim.tbl_contains(test_types, paths[2]))
end

---@async
---@param file_path string
---@return boolean
function adapter.is_test_file(file_path)
    local paths = vim.split(file_path, Path.path.sep)
    return get_test_type(paths)
        and vim.endswith(file_path, ".ts")
        and not vim.endswith(file_path, ".d.ts")
        and not vim.startswith(paths[#paths], "_")
end

---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function adapter.discover_positions(file_path)
    local test_query = [[
    ;; Match describe blocks
    (call_expression
        function: (identifier) @func_name (#eq? @func_name "describe")
        arguments: (arguments
            (string (string_fragment) @namespace.name)
            (arrow_function) @namespace.definition
        )
    )

    ;; Match it blocks
    (call_expression
        function: (identifier) @func_name (#eq? @func_name "it")
        arguments: (arguments
            (string (string_fragment) @test.name)
            (arrow_function) @test.definition
        )
    )
    ]]

    ---@diagnostic disable-next-line: missing-fields
    return lib.treesitter.parse_positions(file_path, test_query, { nested_namespaces = true })
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function adapter.build_spec(args)
    local data = args.tree:data()
    local test_type = get_test_type(data.path)

    local command = { "node", "make", "test:" .. test_type, "-k", '"' .. data.name .. '"' }
    local context = {
        position_id = data.id,
        strategy = args.strategy,
    }
    return {
        command = table.concat(command, " "),
        cwd = root_dir,
        context = context,
    }
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function adapter.results(spec, result, tree)
    local results = {}
    if result.code == 0 then
        results[spec.context.position_id] = {
            status = "passed",
        }
    else
        results[spec.context.position_id] = {
            status = "failed",
            output = result.output,
        }
    end
    return results
end

setmetatable(adapter, {
    __call = function(_, opts)
        if opts.root_dir then root_dir = opts.root_dir end
        return adapter
    end,
})

return adapter
