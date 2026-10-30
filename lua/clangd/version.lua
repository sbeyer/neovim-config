local M = {}
local checked, available, waiting = false, false, {}

function M.ensure(callback)
  if checked then return callback(available) end
  table.insert(waiting, callback)
  if #waiting > 1 then return end

  local requested = vim.g.clangd_version
  local registry = require "mason-registry"

  local function finish(err)
    checked, available = true, vim.fn.executable "clangd" == 1
    if err or not available then
      local fallback = available and ("Using " .. vim.fn.exepath "clangd" .. " for this session.")
        or "No clangd executable is available."
      vim.notify(
        ("Could not ensure clangd %s: %s. %s"):format(requested, tostring(err or "executable missing"), fallback),
        vim.log.levels.WARN,
        { title = "clangd" }
      )
    end
    local callbacks = waiting
    waiting = {}
    for _, ready in ipairs(callbacks) do
      ready(available)
    end
  end

  local function check()
    local ok, package = pcall(registry.get_package, "clangd")
    if not ok then return finish(package) end
    if package:is_installing() then
      -- Share an installation already started by Mason's startup checks.
      package:get_install_handle():get_or_throw():once("closed", vim.schedule_wrap(check))
      return
    end
    if package:is_installed() and package:get_installed_version() == requested then return finish() end

    vim.notify("Installing clangd " .. requested .. " before starting the language server.", vim.log.levels.INFO, {
      title = "clangd",
    })
    local started, err = pcall(
      package.install,
      package,
      { version = requested },
      vim.schedule_wrap(function(success, result)
        if not success then return finish(result) end
        if package:get_installed_version() ~= requested then return finish "installed version does not match" end
        finish()
      end)
    )
    if not started then finish(err) end
  end

  if registry.has_package "clangd" then
    check()
  else
    registry.refresh(vim.schedule_wrap(check))
  end
end

return M
