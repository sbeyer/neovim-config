local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "LuaSnip", "blink.cmp" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
local ls = require "luasnip"
local temporary, buffers, source, original_virtualedit

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
end

local function repository(name)
  local path = vim.fs.joinpath(temporary, name)
  vim.fn.mkdir(vim.fs.joinpath(path, ".git"), "p")
  return path
end

local function snippet(root, filetype, body, scope)
  write(vim.fs.joinpath(root, ".vscode", filetype .. ".code-snippets"), {
    vim.json.encode { Greeting = { prefix = { "hello", "greet" }, body = body, scope = scope } },
  })
end

local function open(path, filetype)
  local buffer = vim.api.nvim_create_buf(true, false)
  table.insert(buffers, buffer)
  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_buf_set_name(buffer, path)
  vim.bo.filetype = filetype
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "hello" })
  vim.api.nvim_win_set_cursor(0, { 1, 5 })
  return buffer
end

local function items()
  local result
  source:get_completions({ line = "hello", cursor = { 1, 5 } }, function(response) result = response.items end)
  return result
end

local function expand()
  assert.is_true(ls.expandable())
  ls.expand()
  return vim.api.nvim_get_current_line()
end

describe("Repository-local VS Code snippets", function()
  before_each(function()
    original_virtualedit = vim.o.virtualedit
    vim.o.virtualedit = "onemore"
    temporary = vim.fn.tempname() .. "-project-snippets"
    vim.fn.mkdir(temporary, "p")
    buffers = {}
    package.loaded["snippets.project"] = nil
    local opts = {}
    dofile("lua/plugins/snippets.lua").opts(nil, opts)
    ls.config.setup(opts)
    source = require("blink.cmp.sources.snippets.luasnip").new {}
  end)

  after_each(function()
    for _, buffer in ipairs(buffers) do
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
    ls.cleanup()
    vim.o.virtualedit = original_virtualedit
    vim.fn.delete(temporary, "rf")
  end)

  it("finds the buffer's repository and follows filetype changes with mapped scopes", function()
    local root = repository "first"
    snippet(root, "django-txt", { "Hello ${1:world}", "$0" }, "django-txt")
    open(vim.fs.joinpath(root, "nested", "example.txt"), "text")
    assert.equals(0, #items())
    assert.is_false(ls.expandable())

    vim.cmd "set ft=django"
    assert.equals(2, #items())
    expand()
    assert.same({ "Hello world", "" }, vim.api.nvim_buf_get_lines(0, 0, -1, false))
    assert.is_true(ls.jumpable(1))
    assert.is_true(ls.jump(1))

    vim.cmd "set ft=text"
    assert.equals(0, #items())
  end)

  it("keeps snippets isolated across repositories and outside them, including cached completions", function()
    local first, second = repository "first", repository "second"
    snippet(first, "django-txt", "First ${1:world}$0", "django-txt")
    snippet(second, "django-txt", "Second ${1:world}$0", "django-txt")
    local first_buffer = open(vim.fs.joinpath(first, "example.txt"), "django")
    assert.equals(2, #items())
    local second_buffer = open(vim.fs.joinpath(second, "example.txt"), "django")
    assert.equals(2, #items())
    assert.equals("Second world", expand())

    vim.api.nvim_set_current_buf(first_buffer)
    assert.equals(2, #items())
    assert.equals("First world", expand())
    open(vim.fs.joinpath(temporary, "outside.txt"), "django")
    assert.equals(0, #items())
    assert.is_false(ls.expandable())
    vim.api.nvim_set_current_buf(second_buffer)
    assert.equals(2, #items())
  end)

  it("keeps unmapped languages, uses filename fallbacks, and preserves ordinary snippets", function()
    local root = repository "first"
    snippet(root, "python", "Hello ${1:world}$0")
    ls.add_snippets("python", { ls.parser.parse_snippet("ordinary", "Ordinary $0") })
    open(vim.fs.joinpath(root, "example.py"), "python")
    assert.equals(3, #items())
    assert.equals("Hello world", expand())
    open(vim.fs.joinpath(temporary, "outside.py"), "python")
    local completions = items()
    assert.equals(1, #completions)
    assert.equals("ordinary", completions[1].label)
  end)

  it("supports JSON comments, multiple scopes, and worktree Git files without inheriting parent snippets", function()
    local root = repository "first"
    write(vim.fs.joinpath(root, ".vscode", "shared.code-snippets"), {
      "{",
      "  // A deliberately simple test snippet.",
      '  "Greeting": { "prefix": "hello", "body": "Hello ${1:world}$0", "scope": "python, django-txt" }',
      "}",
    })
    write(vim.fs.joinpath(root, "worktree", ".git"), { "gitdir: /unused-test-gitdir" })
    open(vim.fs.joinpath(root, "example.py"), "python")
    assert.equals(1, #items())
    vim.cmd "set ft=django"
    assert.equals(1, #items())
    open(vim.fs.joinpath(root, "worktree", "example.txt"), "django")
    assert.equals(0, #items())
  end)
end)
