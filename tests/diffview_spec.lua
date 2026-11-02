local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "diffview.nvim" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
vim.g.mapleader = " "
local specs = dofile "lua/plugins/diffview.lua"
require("astrocore").setup { features = { notifications = false }, mappings = specs[1].opts.mappings }
local opts = dofile(vim.fs.joinpath(lazy, "astrocommunity/lua/astrocommunity/git/diffview-nvim/init.lua")).opts
specs[2].opts(nil, opts)
opts.watch_index, opts.use_icons = false, false
require("diffview").setup(opts)
vim.cmd "runtime plugin/diffview.lua"
local lib = require "diffview.lib"
local temporary, original_cwd, original_columns, original_lines, invoked
local pending = {}

for _, key in ipairs { " e", " bb", " c" } do
  vim.keymap.set("n", key, function() invoked[key] = (invoked[key] or 0) + 1 end)
end

local function git(...)
  local result = vim
    .system(
      vim.list_extend({
        "git",
        "-C",
        temporary,
        "-c",
        "user.name=Test",
        "-c",
        "user.email=test@example.invalid",
      }, { ... }),
      { text = true }
    )
    :wait()
  assert.equals(0, result.code, result.stderr)
  return result.stdout
end

local function write(name, lines) vim.fn.writefile(lines, vim.fs.joinpath(temporary, name)) end

local function wait_for(predicate)
  assert(
    vim.wait(5000, function()
      local view = lib.get_current_view()
      return (not view or (pending[view] or 0) == 0) and predicate()
    end, 20),
    "Diffview did not finish updating"
  )
end

local function type_keys(keys) vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt") end

local function open(keys)
  type_keys(keys or " D<CR>")
  local view = lib.get_current_view()
  assert.is_not_nil(view)
  pending[view] = 0
  view.emitter:on("file_open_pre", function() pending[view] = pending[view] + 1 end)
  view.emitter:on("file_open_post", function() pending[view] = pending[view] - 1 end)
  wait_for(function() return view.ready and view.cur_entry and view.cur_entry.opened end)
  return view
end

local function select_file(view, kind, name)
  local entry
  for _, file in ipairs(view.files[kind]) do
    if file.path == name then entry = file end
  end
  assert.is_not_nil(entry)
  local task = view:set_file(entry, true, true)
  wait_for(
    function()
      return task:is_done() and view.cur_entry == entry and entry.opened and view.cur_layout:get_main_win():is_valid()
    end
  )
  vim.api.nvim_set_current_win(view.cur_layout:get_main_win().id)
  return entry
end

describe("AstroNvim-compatible Diffview", function()
  before_each(function()
    original_cwd, original_columns, original_lines = vim.fn.getcwd(), vim.o.columns, vim.o.lines
    temporary = vim.fn.tempname() .. "-diffview"
    vim.fn.mkdir(temporary, "p")
    git("init", "-qb", "ours")
    vim.api.nvim_set_current_dir(temporary)
    vim.o.columns, vim.o.lines = 180, 50
    invoked = {}
    local lines = {}
    for i = 1, 40 do
      lines[i] = "line " .. i
    end
    write("a.txt", lines)
    write("b.txt", { "original" })
    git("add", ".")
    git("commit", "-qm", "Fixture")
    lines[3], lines[30] = "first change", "second change"
    write("a.txt", lines)
    write("b.txt", { "another change" })
  end)

  after_each(function()
    wait_for(function() return true end)
    vim.cmd "DiffviewClose"
    vim.cmd "silent only!"
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):find(temporary, 1, true) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end
    vim.api.nvim_set_current_dir(original_cwd)
    vim.o.columns, vim.o.lines = original_columns, original_lines
    vim.fn.delete(temporary, "rf")
  end)

  it("toggles its own explorer locally while preserving buffer shortcuts and navigation", function()
    local view = open()
    select_file(view, "working", "a.txt")
    vim.cmd "diffupdate"
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    type_keys "]c"
    assert.equals(3, vim.api.nvim_win_get_cursor(0)[1])
    type_keys "]c"
    assert.equals(30, vim.api.nvim_win_get_cursor(0)[1])
    type_keys "[c"
    assert.equals(3, vim.api.nvim_win_get_cursor(0)[1])
    type_keys "<Tab>"
    wait_for(function() return view.cur_entry.path == "b.txt" and view.cur_entry.opened end)
    type_keys "<S-Tab>"
    wait_for(function() return view.cur_entry.path == "a.txt" and view.cur_entry.opened end)
    for _, key in ipairs { " bb", " c" } do
      type_keys(key)
      assert.equals(1, invoked[key])
    end
    type_keys " e"
    assert.is_false(view.panel:is_open())
    type_keys " e"
    assert.is_true(view.panel:is_open())
    type_keys " Df"
    assert.is_true(view.panel:is_focused())
    type_keys " e"
    assert.is_false(view.panel:is_open())
    assert.is_nil(invoked[" e"])
    type_keys " Df"
    assert.is_true(view.panel:is_focused())
    type_keys " q"
    assert.is_nil(lib.get_current_view())
    assert.equals(1, #vim.api.nvim_list_tabpages())
    type_keys " e"
    assert.equals(1, invoked[" e"])
  end)

  it("also toggles the history panel without invoking the normal explorer", function()
    local view = open " DH"
    assert.is_true(view.panel:is_open())
    type_keys " e"
    assert.is_false(view.panel:is_open())
    type_keys " e"
    assert.is_true(view.panel:is_open())
    assert.is_nil(invoked[" e"])
  end)

  it("stages and unstages files from the panel without discarding working changes", function()
    local view = open()
    select_file(view, "working", "a.txt")
    type_keys " Df"
    type_keys "-"
    wait_for(function() return #view.files.staged == 1 end)
    assert.equals("a.txt\n", git("diff", "--cached", "--name-only"))
    select_file(view, "staged", "a.txt")
    type_keys " Df"
    type_keys "-"
    wait_for(function() return #view.files.staged == 0 end)
    assert.equals("", git("diff", "--cached"))
    assert(vim.fn.readfile(vim.fs.joinpath(temporary, "a.txt"))[3] == "first change")
    type_keys "S"
    wait_for(function() return #view.files.staged == 2 end)
    type_keys "U"
    wait_for(function() return #view.files.staged == 0 end)
    assert.equals("", git("diff", "--cached"))
  end)

  it("stages and unstages one hunk by writing the index buffer", function()
    local view = open()
    select_file(view, "working", "a.txt")
    vim.api.nvim_set_current_win(view.cur_layout.a.id)
    vim.cmd "diffupdate"
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    type_keys "do"
    vim.cmd "write"
    wait_for(function() return #view.files.staged == 1 end)
    local staged = git("show", ":a.txt")
    assert(staged:find("first change", 1, true))
    assert.is_nil(staged:find("second change", 1, true))
    select_file(view, "staged", "a.txt")
    vim.api.nvim_set_current_win(view.cur_layout.b.id)
    vim.cmd "diffupdate"
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    type_keys "do"
    vim.cmd "write"
    wait_for(function() return #view.files.staged == 0 end)
    assert.equals("", git("diff", "--cached"))
    local working = vim.fn.readfile(vim.fs.joinpath(temporary, "a.txt"))
    assert.equals("first change", working[3])
    assert.equals("second change", working[30])
  end)

  it("navigates and resolves conflicts with the remapped choices before staging the result", function()
    git("restore", ".")
    git("switch", "-qc", "theirs")
    local theirs = vim.fn.readfile(vim.fs.joinpath(temporary, "a.txt"))
    theirs[3], theirs[30] = "their first", "their second"
    write("a.txt", theirs)
    git("commit", "-qam", "Theirs")
    git("switch", "-q", "ours")
    local ours = vim.fn.readfile(vim.fs.joinpath(temporary, "a.txt"))
    ours[3], ours[30] = "our first", "our second"
    write("a.txt", ours)
    git("commit", "-qam", "Ours")
    local result = vim
      .system({
        "git",
        "-C",
        temporary,
        "-c",
        "merge.conflictStyle=diff3",
        "merge",
        "--no-edit",
        "theirs",
      }, { text = true })
      :wait()
    assert.equals(1, result.code, result.stderr)
    local view = open()
    select_file(view, "conflicting", "a.txt")
    type_keys " Do"
    type_keys "]x"
    type_keys " Dt"
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    assert.equals("our first", lines[3])
    assert.equals("their second", lines[30])
    assert.is_nil(table.concat(lines, "\n"):find("<<<<<<<", 1, true))
    assert(git("diff", "--name-only", "--diff-filter=U"):find("a.txt", 1, true))
    vim.cmd "write"
    type_keys " Df"
    type_keys "-"
    wait_for(function() return #view.files.conflicting == 0 end)
    assert.equals("", git("diff", "--name-only", "--diff-filter=U"))
    assert(git("show", ":a.txt"):find("our first", 1, true))
    assert(git("show", ":a.txt"):find("their second", 1, true))
  end)
end)
