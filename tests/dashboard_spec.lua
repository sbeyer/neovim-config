local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local opts = { dashboard = { preset = { keys = {} } } }
dofile("lua/plugins/snacks.lua")[2].opts(nil, opts)
local changes
for _, item in ipairs(opts.dashboard.preset.keys) do
  if item.key == "g" then changes = item end
end
local temporary, original_cwd

local function git(...)
  local result = vim.system(vim.list_extend({ "git" }, { ... }), { text = true }):wait()
  assert.equals(0, result.code, result.stderr)
  return result.stdout
end

describe("Dashboard Git changes", function()
  before_each(function()
    original_cwd = vim.fn.getcwd()
    temporary = vim.fn.tempname() .. "-dashboard"
    vim.fn.mkdir(temporary, "p")
    vim.api.nvim_set_current_dir(temporary)
    git("init", "-q")
    vim.fn.writefile({ "original" }, "tracked.txt")
    vim.fn.writefile({ "ignored.txt" }, ".gitignore")
    git("add", ".")
    git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-qm", "Fixture")
  end)

  after_each(function()
    vim.api.nvim_set_current_dir(original_cwd)
    vim.fn.delete(temporary, "rf")
  end)

  it("hides in a clean repository, including ignored files", function()
    vim.fn.writefile({ "ignored" }, "ignored.txt")
    assert.is_false(changes.enabled())
  end)

  it("shows unstaged changes and rechecks when they are removed", function()
    vim.fn.writefile({ "modified" }, "tracked.txt")
    assert.is_true(changes.enabled())
    assert.equals("<Leader>gt", changes.action)
    vim.fn.writefile({ "original" }, "tracked.txt")
    assert.is_false(changes.enabled())
  end)

  it("shows staged changes", function()
    vim.fn.writefile({ "modified" }, "tracked.txt")
    git("add", "tracked.txt")
    assert.is_true(changes.enabled())
  end)

  it("shows untracked files even from a repository subdirectory", function()
    vim.fn.writefile({ "new" }, "untracked.txt")
    vim.fn.mkdir "nested"
    vim.api.nvim_set_current_dir(temporary .. "/nested")
    assert.is_true(changes.enabled())
  end)

  it("hides outside a Git repository", function()
    vim.fn.delete(temporary .. "/.git", "rf")
    assert.is_false(changes.enabled())
  end)
end)
