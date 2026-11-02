local M = {}
local projects = {}

function M.read(root)
  if not root then return {} end
  if projects[root] then return projects[root] end
  projects[root] = {}
  local path = vim.fs.joinpath(root, ".vscode", "settings.json")
  if vim.fn.filereadable(path) == 0 then return projects[root] end
  local ok, settings = pcall(function()
    local result = require("luasnip.util.jsonc").decode(table.concat(vim.fn.readfile(path), "\n"))
    assert(type(result) == "table", "Expected a settings object")
    return result
  end)
  if ok then
    projects[root] = settings
  else
    vim.schedule(
      function()
        vim.notify("Could not load " .. path .. ": " .. tostring(settings), vim.log.levels.WARN, {
          title = "VS Code settings",
        })
      end
    )
  end
  return projects[root]
end

return M
