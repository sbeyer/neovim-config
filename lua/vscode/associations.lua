local M = {}
local projects = {}
local filetypes = require "vscode.filetypes"

local function read(root)
  local path = vim.fs.joinpath(root, ".vscode", "settings.json")
  if vim.fn.filereadable(path) == 0 then return {} end
  local settings = require("luasnip.util.jsonc").decode(table.concat(vim.fn.readfile(path), "\n"))
  local associations = {}
  for pattern, language in pairs(settings["files.associations"] or {}) do
    assert(type(language) == "string" and language ~= "", "Invalid language for " .. tostring(pattern))
    table.insert(associations, {
      pattern = pattern,
      matcher = vim.glob.to_lpeg(pattern:lower()),
      filetype = filetypes[language] or language,
      path = pattern:find("/", 1, true) ~= nil,
    })
  end
  -- VS Code prefers longer matching patterns; break equal-length ties consistently.
  table.sort(associations, function(a, b)
    if #a.pattern ~= #b.pattern then return #a.pattern > #b.pattern end
    return a.pattern < b.pattern
  end)
  return associations
end

local function match(name)
  local root = vim.fs.root(vim.fs.dirname(name), ".git")
  if not root then return end
  if not projects[root] then
    local ok, associations = pcall(read, root)
    projects[root] = ok and associations or {}
    if not ok then
      vim.schedule(
        function()
          vim.notify(
            "Could not load " .. vim.fs.joinpath(root, ".vscode", "settings.json") .. ": " .. tostring(associations),
            vim.log.levels.WARN,
            { title = "VS Code file associations" }
          )
        end
      )
    end
  end
  -- Language associations in VS Code are case-insensitive.
  name = name:lower()
  local basename = vim.fs.basename(name)
  for _, association in ipairs(projects[root]) do
    if association.matcher:match(association.path and name or basename) then return association.filetype end
  end
end

function M.register(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" or vim.bo[bufnr].buftype ~= "" then return end
  local filetype = match(name)
  if filetype then vim.filetype.add { filename = { [name] = filetype } } end
end

return M
