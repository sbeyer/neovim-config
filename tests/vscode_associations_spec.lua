local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "LuaSnip" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
vim.cmd "filetype on"
local core_opts = { features = { notifications = false }, autocmds = {} }
dofile("lua/plugins/vscode.lua").opts(nil, core_opts)
require("astrocore").setup(core_opts)
local ls = require "luasnip"
local snippet_opts = {}
dofile("lua/plugins/snippets.lua").opts(nil, snippet_opts)
ls.config.setup(snippet_opts)

local temporary, buffers, detected, original_notify, notifications, group

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
end

local function repository(name, associations)
  local root = vim.fs.joinpath(temporary, name)
  vim.fn.mkdir(vim.fs.joinpath(root, ".git"), "p")
  if associations then
    write(vim.fs.joinpath(root, ".vscode", "settings.json"), {
      vim.json.encode { ["files.associations"] = associations },
    })
  end
  return root
end

local function open(path, existing)
  if existing then write(path, { "" }) end
  vim.cmd.edit(vim.fn.fnameescape(path))
  local buffer = vim.api.nvim_get_current_buf()
  table.insert(buffers, buffer)
  return vim.bo.filetype
end

describe("Repository-local VS Code file associations", function()
  before_each(function()
    temporary = vim.fn.tempname() .. "-vscode-associations"
    vim.fn.mkdir(temporary, "p")
    buffers, detected, notifications = {}, {}, {}
    package.loaded["vscode.associations"] = nil
    original_notify = vim.notify
    vim.notify = function(message) table.insert(notifications, message) end
    group = vim.api.nvim_create_augroup("test_vscode_filetypes", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(event)
        detected[event.buf] = detected[event.buf] or {}
        table.insert(detected[event.buf], event.match)
      end,
    })
  end)

  after_each(function()
    vim.api.nvim_del_augroup_by_id(group)
    for _, buffer in ipairs(buffers) do
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
    ls.cleanup()
    vim.notify = original_notify
    vim.fn.delete(temporary, "rf")
  end)

  it("maps existing and new files before their first FileType event, including native filename rules", function()
    local root = repository("first", { ["*.cpp"] = "django-txt", Makefile = "django-txt" })
    assert.equals("django", open(vim.fs.joinpath(root, "nested", "hello.cpp"), true))
    assert.same({ "django" }, detected[vim.api.nvim_get_current_buf()])
    assert.equals("django", open(vim.fs.joinpath(root, "Makefile")))
    assert.same({ "django" }, detected[vim.api.nvim_get_current_buf()])
  end)

  it("registers startup buffers that were created before the association hooks", function()
    local root = repository("first", { ["*.cpp"] = "django-txt" })
    local buffer = vim.api.nvim_create_buf(true, false)
    table.insert(buffers, buffer)
    vim.api.nvim_buf_set_name(buffer, vim.fs.joinpath(root, "new.cpp"))
    vim.api.nvim_set_current_buf(buffer)
    dofile("lua/plugins/vscode.lua").opts(nil, { autocmds = {} })
    vim.api.nvim_exec_autocmds("BufNewFile", { buffer = buffer })
    assert.equals("django", vim.bo.filetype)
    assert.same({ "django" }, detected[buffer])
  end)

  it("keeps associations local to the nearest repository and leaves unmatched filetypes unchanged", function()
    local first = repository("first", { ["*.cpp"] = "django-txt" })
    local second = repository "second"
    assert.equals("django", open(vim.fs.joinpath(first, "hello.cpp"), true))
    assert.equals("cpp", open(vim.fs.joinpath(second, "hello.cpp"), true))
    assert.equals("cpp", open(vim.fs.joinpath(temporary, "hello.cpp"), true))
    assert.equals("python", open(vim.fs.joinpath(first, "hello.py"), true))
    write(vim.fs.joinpath(first, "worktree", ".git"), { "gitdir: /unused-test-gitdir" })
    assert.equals("cpp", open(vim.fs.joinpath(first, "worktree", "hello.cpp"), true))
  end)

  it("reads JSON comments and trailing commas, maps languages, and enables matching snippets automatically", function()
    local root = repository "first"
    write(vim.fs.joinpath(root, ".vscode", "settings.json"), {
      "{",
      "  // Only language associations should affect Neovim.",
      '  "files.associations": { "*.tmpl": "django-txt", },',
      '  "editor.tabSize": 7,',
      "}",
    })
    write(vim.fs.joinpath(root, ".vscode", "django-txt.code-snippets"), {
      vim.json.encode { Greeting = { prefix = "hello", body = "Hello ${1:world}$0", scope = "django-txt" } },
    })
    assert.equals("django", open(vim.fs.joinpath(root, "hello.tmpl"), true))
    local snippet
    for _, ft in ipairs(ls.get_snippet_filetypes()) do
      for _, candidate in ipairs(ls.get_snippets(ft)) do
        if candidate.trigger == "hello" then snippet = candidate end
      end
    end
    assert.is_not_nil(snippet)
    ls.snip_expand(snippet)
    assert.equals("Hello world", vim.api.nvim_get_current_line())
  end)

  it("supports filename and path globs with deterministic longest-pattern precedence", function()
    local root = repository("first", {
      ["*.cpp"] = "python",
      ["hello*.cpp"] = "django-txt",
      ["**/templates/*.{txt,tmpl}"] = "python",
      ["**/data/item[0-9]?.txt"] = "django-txt",
    })
    assert.equals("django", open(vim.fs.joinpath(root, "nested", "HELLO.cpp"), true))
    assert.equals("python", open(vim.fs.joinpath(root, "other.cpp"), true))
    assert.equals("python", open(vim.fs.joinpath(root, "templates", "hello.tmpl"), true))
    assert.equals("django", open(vim.fs.joinpath(root, "data", "item1a.txt"), true))
  end)

  it("warns once for malformed settings and retains native filetype detection", function()
    local root = repository "first"
    write(vim.fs.joinpath(root, ".vscode", "settings.json"), { "{ invalid JSON" })
    assert.equals("cpp", open(vim.fs.joinpath(root, "hello.cpp"), true))
    assert.is_true(vim.wait(100, function() return #notifications > 0 end))
    assert.equals("cpp", open(vim.fs.joinpath(root, "other.cpp"), true))
    assert.equals(1, #notifications)
    assert.is_not_nil(notifications[1]:find("settings.json", 1, true))
  end)
end)
