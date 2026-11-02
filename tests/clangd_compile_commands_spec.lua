-- Test the Compilation database finder's discovery, deduplication, selection, reuse, and cancellation.
-- Use Plenary and temporary projects, without starting clangd or loading AstroNvim.
-- Run with: ./tests/run.sh

local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local temporary, finder, scheduled, notifications
local original_select, original_schedule, original_notify, original_config

local function flush_scheduled()
  while #scheduled > 0 do
    table.remove(scheduled, 1)()
  end
end

local function fixture(name, databases)
  local root = vim.fs.joinpath(temporary, name)
  vim.fn.mkdir(vim.fs.joinpath(root, ".git"), "p")
  local source = vim.fs.joinpath(root, "Source", "main.cpp")
  vim.fn.mkdir(vim.fs.dirname(source), "p")
  vim.fn.writefile({ "int main() {}" }, source)
  for _, directory in ipairs(databases) do
    local path = vim.fs.joinpath(root, directory)
    vim.fn.mkdir(path, "p")
    vim.fn.writefile({ "[]" }, vim.fs.joinpath(path, "compile_commands.json"))
  end
  return root, vim.fn.bufadd(source)
end

local function initialize(config, root)
  local params = { initializationOptions = { fallbackFlags = { "-std=c++20" } } }
  config.before_init(params, { root_dir = root })
  assert(params.initializationOptions.fallbackFlags[1] == "-std=c++20")
  return params.initializationOptions.compilationDatabasePath
end

local function test(name, databases, run)
  it(name, function()
    local root, buffer = fixture(name, databases)
    run(finder, root, buffer, flush_scheduled)
    assert(#scheduled == 0, "Scheduled work was not processed")
  end)
end

describe("Compilation database finder", function()
  before_each(function()
    temporary = vim.fn.tempname() .. "-clangd-tests"
    assert(vim.fn.isdirectory(temporary) == 0)
    vim.fn.mkdir(temporary, "p")
    original_select, original_schedule, original_notify = vim.ui.select, vim.schedule, vim.notify
    original_config = vim.lsp.config.clangd
    vim.lsp.config.clangd = { root_markers = { "compile_commands.json", ".git" } }
    finder = dofile "lua/clangd/compile-commands.lua"
    scheduled, notifications = {}, {}
    vim.schedule = function(callback) table.insert(scheduled, callback) end
    vim.ui.select = function() error "Unexpected database selection prompt" end
    vim.notify = function(message, level, opts)
      table.insert(notifications, { message = message, level = level, opts = opts })
    end
  end)

  after_each(function()
    vim.ui.select, vim.schedule, vim.notify = original_select, original_schedule, original_notify
    vim.lsp.config.clangd = original_config
    vim.fn.delete(temporary, "rf")
  end)

  test(
    "chooses compile_commands.json from the project root when it is the only database",
    { "." },
    function(config, root, buffer)
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      assert(initialize(config, root) == root)
    end
  )

  test(
    "treats a root symlink and its build database as one compile_commands.json",
    { "build-x86_64" },
    function(config, root, buffer)
      assert(vim.uv.fs_symlink("build-x86_64/compile_commands.json", vim.fs.joinpath(root, "compile_commands.json")))
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      assert(initialize(config, root) == root)
    end
  )

  test(
    "chooses compile_commands.json from the only matching build directory",
    { "build-release", "other-build" },
    function(config, root, buffer)
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-release"))
    end
  )

  test("ignores a broken root symlink when a build database exists", { "build" }, function(config, root, buffer)
    assert(vim.uv.fs_symlink("missing.json", vim.fs.joinpath(root, "compile_commands.json")))
    config.root_dir(buffer, function(directory) assert(directory == root) end)
    assert(initialize(config, root) == vim.fs.joinpath(root, "build"))
  end)

  test(
    "keeps native database discovery when no compile_commands.json is found",
    { "unrelated" },
    function(config, root, buffer, flush)
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      flush()
      assert(initialize(config, root) == nil)
    end
  )

  test("shows an error notification when no compile_commands.json is found", {}, function(config, root, buffer, flush)
    config.root_dir(buffer, function() end)
    assert(#notifications == 0)
    flush()
    assert(#notifications == 1)
    assert(notifications[1].level == vim.log.levels.ERROR)
    assert(notifications[1].opts.title == "clangd")
    assert(notifications[1].message:find("compile_commands.json", 1, true))
    assert(notifications[1].message:find(root, 1, true))
  end)

  test("reports missing compile_commands.json only once per project", {}, function(config, _, buffer, flush)
    config.root_dir(buffer, function() end)
    flush()
    config.root_dir(buffer, function() end)
    flush()
    assert(#notifications == 1)
  end)

  test(
    "offers root and build databases when they contain distinct compile_commands.json files",
    { ".", "build-x86_64", "build-debug" },
    function(config, root, buffer, flush)
      vim.ui.select = function(items, opts, callback)
        assert(
          vim.deep_equal(items, { root, vim.fs.joinpath(root, "build-x86_64"), vim.fs.joinpath(root, "build-debug") })
        )
        assert(opts.format_item(items[1]) == "compile_commands.json")
        callback(items[3])
      end
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      flush()
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-debug"))
    end
  )

  test(
    "offers other builds even when build-x86_64 has a compile_commands.json",
    { "build-x86_64", "build-debug" },
    function(config, root, buffer, flush)
      vim.ui.select = function(items, _, callback)
        assert(vim.deep_equal(items, { vim.fs.joinpath(root, "build-x86_64"), vim.fs.joinpath(root, "build-debug") }))
        callback(items[2])
      end
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      flush()
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-debug"))
    end
  )

  test(
    "deduplicates file and directory symlinks before offering databases",
    { "build-x86_64", "build-debug" },
    function(config, root, buffer, flush)
      assert(vim.uv.fs_symlink("build-x86_64/compile_commands.json", vim.fs.joinpath(root, "compile_commands.json")))
      assert(vim.uv.fs_symlink("build-x86_64", vim.fs.joinpath(root, "build-alias")))
      vim.ui.select = function(items, _, callback)
        assert(vim.deep_equal(items, { root, vim.fs.joinpath(root, "build-debug") }))
        callback(items[1])
      end
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      flush()
      assert(initialize(config, root) == root)
    end
  )

  test(
    "shares one pending database picker between simultaneous buffers",
    { "build-release", "build-debug" },
    function(config, root, buffer, flush)
      local selection, prompts, started = nil, 0, 0
      vim.ui.select = function(items, opts, callback)
        prompts = prompts + 1
        assert(#items == 2)
        assert(opts.format_item(items[1]) == "build-debug/compile_commands.json")
        selection = function() callback(items[2]) end
      end
      local function on_dir(directory)
        assert(directory == root)
        started = started + 1
      end
      config.root_dir(buffer, on_dir)
      config.root_dir(buffer, on_dir)
      assert(prompts == 0 and started == 0)
      flush()
      assert(prompts == 1 and started == 0)
      selection()
      assert(started == 2)
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-release"))
    end
  )

  test(
    "reuses the selected compile_commands.json during the session",
    { "build-debug", "build-release" },
    function(config, root, buffer, flush)
      local prompts, started = 0, 0
      vim.ui.select = function(items, _, callback)
        prompts = prompts + 1
        callback(items[2])
      end
      local function on_dir(directory)
        assert(directory == root)
        started = started + 1
      end
      config.root_dir(buffer, on_dir)
      flush()
      config.root_dir(buffer, on_dir)
      assert(prompts == 1 and started == 2)
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-release"))
    end
  )

  test(
    "chooses the first compile_commands.json when the picker is cancelled",
    { ".", "build-x86_64", "build-debug" },
    function(config, root, buffer, flush)
      local started = false
      vim.ui.select = function(_, _, callback) callback(nil) end
      config.root_dir(buffer, function(directory)
        assert(directory == root)
        started = true
      end)
      flush()
      assert(started)
      assert(initialize(config, root) == root)
    end
  )

  test(
    "reuses the first compile_commands.json after cancellation without prompting again",
    { "build-x86_64", "build-debug" },
    function(config, root, buffer, flush)
      local prompts, started = 0, 0
      vim.ui.select = function(_, _, callback)
        prompts = prompts + 1
        callback(nil)
      end
      local function on_dir(directory)
        assert(directory == root)
        started = started + 1
      end
      config.root_dir(buffer, on_dir)
      flush()
      config.root_dir(buffer, on_dir)
      assert(prompts == 1 and started == 2)
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-x86_64"))
    end
  )

  test(
    "opens the database picker after edit processing finishes",
    { "build-debug", "build-release" },
    function(config, root, buffer, flush)
      local editing = true
      vim.ui.select = function(items, _, callback)
        assert(not editing, "Picker opened before edit processing finished")
        callback(items[1])
      end
      config.root_dir(buffer, function(directory) assert(directory == root) end)
      editing = false
      flush()
      assert(initialize(config, root) == vim.fs.joinpath(root, "build-debug"))
    end
  )
end)
