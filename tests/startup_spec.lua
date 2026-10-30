local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local settings = require "config"
local check = dofile("lua/plugins/astrocore.lua").opts.autocmds.nvim_version_check[1].callback
local original_version, original_notify, original_supported, version, notifications

describe("Startup version check", function()
  before_each(function()
    original_version, original_notify = vim.version, vim.notify
    original_supported = settings.supported_nvim_version
    settings.supported_nvim_version = "0.12.6"
    version, notifications = "0.11.6", {}
    vim.version = function() return original_version.parse(version) end
    vim.notify = function(message, level, opts)
      notifications[#notifications + 1] = { message = message, level = level, title = opts.title }
    end
  end)

  after_each(function()
    vim.version, vim.notify = original_version, original_notify
    settings.supported_nvim_version = original_supported
  end)

  it("warns without blocking and identifies the running version and executable", function()
    check()
    assert(vim.wait(1000, function() return #notifications > 0 end))
    assert.equals(1, #notifications)
    local notification = notifications[1]
    assert.equals(vim.log.levels.WARN, notification.level)
    assert(notification.message:find("0.12.6", 1, true))
    assert(notification.message:find(tostring(vim.version()), 1, true))
    assert(notification.message:find(vim.v.progpath, 1, true))
  end)

  it("uses the centrally configured release when it changes", function()
    settings.supported_nvim_version = "0.13.2"
    version = "0.13.3"
    check()
    local done = false
    vim.schedule(function() done = true end)
    assert(vim.wait(1000, function() return done end))
    assert.same({}, notifications)
  end)

  for _, case in ipairs {
    { version = "0.12.5", warn = true },
    { version = "0.12.6", warn = false },
    { version = "0.12.7", warn = false },
    { version = "0.13.0", warn = true },
    { version = "1.0.0", warn = true },
  } do
    it((case.warn and "warns for " or "allows ") .. case.version, function()
      version = case.version
      check()
      local done = false
      vim.schedule(function() done = true end)
      assert(vim.wait(1000, function() return done end))
      assert.equals(case.warn and 1 or 0, #notifications)
    end)
  end
end)
