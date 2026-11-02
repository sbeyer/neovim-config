local M = {}
local loaded = {}
local vscode_filetypes = require "vscode.filetypes"

local function namespace(root, filetype) return "project-snippets:" .. root .. ":" .. filetype end

local function read_snippets(path, filetype, root)
  local ls = require "luasnip"
  local definitions = require("luasnip.util.jsonc").decode(table.concat(vim.fn.readfile(path), "\n"))
  local snippets = {}
  for name, definition in pairs(definitions) do
    local body = definition.body
    if type(body) == "table" then body = table.concat(body, "\n") end
    local prefixes = definition.prefix
    if type(prefixes) == "string" then prefixes = { prefixes } end
    for language in (definition.scope or filetype):gmatch "[^,]+" do
      language = vim.trim(language)
      language = vscode_filetypes[language] or language
      local ft = namespace(root, language)
      snippets[ft] = snippets[ft] or {}
      for _, prefix in ipairs(prefixes) do
        table.insert(
          snippets[ft],
          ls.parser.parse_snippet({ trig = prefix, name = name, desc = definition.description }, body, {
            trim_empty = false,
            dedent = false,
          })
        )
      end
    end
  end
  return snippets
end

local function load(root)
  loaded[root] = true
  local directory = vim.fs.joinpath(root, ".vscode")
  if vim.fn.isdirectory(directory) == 0 then return end
  for name, kind in vim.fs.dir(directory) do
    local filetype = name:match "^(.*)%.code%-snippets$"
    if filetype and (kind == "file" or kind == "link") then
      local path = vim.fs.joinpath(directory, name)
      local ok, snippets = pcall(read_snippets, path, filetype, root)
      if ok then
        require("luasnip").add_snippets(nil, snippets, { key = path })
      else
        vim.schedule(
          function()
            vim.notify("Could not load " .. path .. ": " .. tostring(snippets), vim.log.levels.WARN, {
              title = "Project snippets",
            })
          end
        )
      end
    end
  end
end

function M.filetypes(filetypes)
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" or vim.bo.buftype ~= "" then return filetypes end
  local root = vim.fs.root(vim.fs.dirname(name), ".git")
  if not root then return filetypes end
  if not loaded[root] then load(root) end

  -- Separate snippet filetypes also isolate Blink's completion cache per repository.
  local result = {}
  for _, filetype in ipairs(filetypes) do
    table.insert(result, namespace(root, filetype))
  end
  table.insert(result, namespace(root, "all"))
  return vim.list_extend(result, filetypes)
end

return M
