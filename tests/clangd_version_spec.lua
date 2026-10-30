local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local settings = require "config"
local ensure, clangd, registry, installed, installing, executable
local installs, notifications, scheduled, closed
local original_registry, original_version, original_notify, original_schedule, original_executable, original_exepath

local function flush()
  while #scheduled > 0 do
    table.remove(scheduled, 1)()
  end
end

describe("Clangd version pin", function()
  before_each(function()
    original_registry = package.loaded["mason-registry"]
    original_version, original_notify, original_schedule = settings.clangd_version, vim.notify, vim.schedule
    original_executable, original_exepath = vim.fn.executable, vim.fn.exepath
    settings.clangd_version = "21.1.8"
    installed, installing, executable = "21.1.8", false, true
    installs, notifications, scheduled, closed = {}, {}, {}, nil
    clangd = {
      is_installed = function() return installed ~= nil end,
      get_installed_version = function() return installed end,
      is_installing = function() return installing end,
      get_install_handle = function()
        return {
          get_or_throw = function()
            return {
              once = function(_, event, callback)
                assert.equals("closed", event)
                closed = callback
              end,
            }
          end,
        }
      end,
      install = function(_, opts, callback) table.insert(installs, { opts = opts, callback = callback }) end,
    }
    registry = {
      has_package = function() return true end,
      get_package = function(name)
        assert.equals("clangd", name)
        return clangd
      end,
      refresh = function(callback) callback() end,
    }
    package.loaded["mason-registry"] = registry
    vim.notify = function(message, level) table.insert(notifications, { message = message, level = level }) end
    vim.schedule = function(callback) table.insert(scheduled, callback) end
    vim.fn.executable = function(name)
      assert.equals("clangd", name)
      return executable and 1 or 0
    end
    vim.fn.exepath = function() return "/mason/bin/clangd" end
    ensure = dofile("lua/clangd/version.lua").ensure
  end)

  after_each(function()
    package.loaded["mason-registry"] = original_registry
    settings.clangd_version, vim.notify, vim.schedule = original_version, original_notify, original_schedule
    vim.fn.executable, vim.fn.exepath = original_executable, original_exepath
  end)

  it("checks a matching version only once per session without installing", function()
    local calls = 0
    ensure(function(available)
      assert.is_true(available)
      calls = calls + 1
    end)
    registry.get_package = function() error "Version was checked twice" end
    ensure(function(available)
      assert.is_true(available)
      calls = calls + 1
    end)
    assert.equals(2, calls)
    assert.same({}, installs)
    assert.same({}, notifications)
  end)

  for _, case in ipairs { { version = "23.1.0", name = "a different" }, { name = "a missing" } } do
    it("installs the configured version for " .. case.name .. " clangd and shares the wait between buffers", function()
      installed = case.version
      local calls = 0
      local function ready(available)
        assert.is_true(available)
        calls = calls + 1
      end
      ensure(ready)
      ensure(ready)
      assert.equals(1, #installs)
      assert.equals("21.1.8", installs[1].opts.version)
      assert.equals(0, calls)
      installed = "21.1.8"
      installs[1].callback(true)
      assert.equals(0, calls)
      flush()
      assert.equals(2, calls)
    end)
  end

  it("waits for another installation and corrects its version before allowing startup", function()
    installed, installing = "23.1.0", true
    local ready
    ensure(function(available) ready = available end)
    assert.is_nil(ready)
    assert.same({}, installs)
    installing = false
    closed()
    flush()
    assert.equals(1, #installs)
    assert.equals("21.1.8", installs[1].opts.version)
    installed = "21.1.8"
    installs[1].callback(true)
    flush()
    assert.is_true(ready)
  end)

  it("reuses another installation when it finishes with the requested version", function()
    installing = true
    local ready
    ensure(function(available) ready = available end)
    installing = false
    closed()
    flush()
    assert.is_true(ready)
    assert.same({}, installs)
  end)

  it("warns and uses the available executable on failure without retrying for every buffer", function()
    installed = "23.1.0"
    local calls = 0
    local function ready(available)
      assert.is_true(available)
      calls = calls + 1
    end
    ensure(ready)
    installs[1].callback(false, "download failed")
    flush()
    ensure(ready)
    assert.equals(2, calls)
    assert.equals(1, #installs)
    local warning = notifications[#notifications]
    assert.equals(vim.log.levels.WARN, warning.level)
    assert(warning.message:find("download failed", 1, true))
    assert(warning.message:find("Using /mason/bin/clangd", 1, true))
  end)

  it("does not start a nonexistent fallback executable when installation fails", function()
    installed, executable = nil, false
    local ready
    ensure(function(available) ready = available end)
    installs[1].callback(false, "offline")
    flush()
    assert.is_false(ready)
    assert(notifications[#notifications].message:find("No clangd executable", 1, true))
  end)

  it("refreshes a missing registry before checking and honors a changed central version", function()
    settings.clangd_version = "20.1.0"
    registry.has_package = function() return false end
    local refreshed = false
    registry.refresh = function(callback)
      refreshed = true
      callback()
    end
    ensure(function() end)
    flush()
    assert.is_true(refreshed)
    assert.equals("20.1.0", installs[1].opts.version)
  end)

  it("falls back if the installer cannot even start", function()
    installed = "23.1.0"
    clangd.install = function() error "installer unavailable" end
    local ready
    ensure(function(available) ready = available end)
    assert.is_true(ready)
    assert(notifications[#notifications].message:find("installer unavailable", 1, true))
  end)

  it("pins both automatic installers while preserving other tools and clangd options", function()
    settings.clangd_version = "20.1.0"
    local specs = dofile "lua/plugins/mason.lua"
    local lsp = { ensure_installed = { "lua_ls", "clangd@23.1.0" } }
    local tools = { ensure_installed = { "stylua", { "clangd", auto_update = false } } }
    specs[1].opts(nil, lsp)
    specs[2].opts(nil, tools)
    assert.same({ "lua_ls", "clangd@20.1.0" }, lsp.ensure_installed)
    assert.same({ "stylua", { "clangd", version = "20.1.0", auto_update = false } }, tools.ensure_installed)
  end)
end)

describe("Clangd startup integration", function()
  it("waits for the version check before discovering the compilation database and ignores deleted buffers", function()
    local original_finder, original_guard = package.loaded["clangd.compile-commands"], package.loaded["clangd.version"]
    local pending, roots = nil, 0
    package.loaded["clangd.compile-commands"] = {
      root_dir = function(_, on_dir)
        roots = roots + 1
        on_dir "/project"
      end,
    }
    package.loaded["clangd.version"] = { ensure = function(callback) pending = callback end }
    local buffer = vim.api.nvim_create_buf(true, false)
    local ok, err = pcall(function()
      local config = dofile "lsp/clangd.lua"
      local root
      config.root_dir(buffer, function(directory) root = directory end)
      assert.is_nil(root)
      pending(true)
      assert.equals("/project", root)
      config.root_dir(buffer, function() error "Deleted buffer started clangd" end)
      vim.api.nvim_buf_delete(buffer, { force = true })
      pending(true)
      assert.equals(1, roots)
    end)
    package.loaded["clangd.compile-commands"], package.loaded["clangd.version"] = original_finder, original_guard
    if vim.api.nvim_buf_is_valid(buffer) then vim.api.nvim_buf_delete(buffer, { force = true }) end
    assert(ok, err)
  end)
end)
