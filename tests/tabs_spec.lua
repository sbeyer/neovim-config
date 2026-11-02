local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each
local tabs = require "tabs"

local original_tab, original_buf, original_select, original_notify, buffers, selection, prefix

local function buffer(name)
  local buf = vim.api.nvim_create_buf(false, true)
  buffers[#buffers + 1] = buf
  if name then vim.api.nvim_buf_set_name(buf, vim.fs.joinpath(prefix, name)) end
  vim.api.nvim_win_set_buf(0, buf)
  return buf
end

local function new_tab(name)
  vim.cmd "tabnew"
  buffer(name)
  return vim.api.nvim_get_current_tabpage()
end

local function close_tab(tab) vim.cmd("tabclose! " .. vim.api.nvim_tabpage_get_number(tab)) end

describe("Tab picker and recent-tab history", function()
  before_each(function()
    original_tab, original_buf = vim.api.nvim_get_current_tabpage(), vim.api.nvim_get_current_buf()
    original_select, original_notify = vim.ui.select, vim.notify
    buffers, selection, prefix = {}, nil, vim.fn.tempname() .. "-tabs"
    buffer "alpha.lua"
    tabs.setup()
    vim.ui.select = function(items, opts, choose) selection = { items = items, opts = opts, choose = choose } end
  end)

  after_each(function()
    vim.api.nvim_set_current_tabpage(original_tab)
    vim.cmd "silent tabonly!"
    vim.cmd "silent only!"
    vim.api.nvim_win_set_buf(0, original_buf)
    for _, buf in ipairs(buffers) do
      if vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end
    vim.ui.select, vim.notify = original_select, original_notify
  end)

  it("lists tabs with their files and current marker, ignoring floats and duplicate buffers", function()
    vim.cmd "vsplit"
    buffer "nested/beta.lua"
    vim.cmd "vsplit"
    local floating = vim.api.nvim_create_buf(false, true)
    buffers[#buffers + 1] = floating
    vim.api.nvim_buf_set_name(floating, vim.fs.joinpath(prefix, "floating.lua"))
    vim.api.nvim_open_win(floating, false, { relative = "editor", row = 1, col = 1, width = 10, height = 2 })
    local unnamed = new_tab()
    tabs.pick()
    assert.equals(2, #selection.items)
    assert.equals(original_tab, selection.items[1].tab)
    local label = selection.opts.format_item(selection.items[1])
    assert.is_truthy(label:find("alpha.lua", 1, true))
    assert.is_truthy(label:find("nested/beta.lua", 1, true))
    local _, occurrences = label:gsub("beta%.lua", "")
    assert.equals(1, occurrences)
    assert.is_nil(label:find("floating.lua", 1, true))
    assert.is_nil(label:find("[current]", 1, true))
    assert.equals(unnamed, selection.items[2].tab)
    assert.equals("[No Name] [current]", selection.opts.format_item(selection.items[2]))
  end)

  it("selects the same tab even after tabs are reordered and another tab closes", function()
    local other = new_tab "beta.lua"
    local target = new_tab "gamma.lua"
    tabs.pick()
    local choice = selection.items[3]
    vim.cmd "tabmove 0"
    vim.api.nvim_set_current_tabpage(original_tab)
    close_tab(other)
    selection.choose(choice)
    assert.equals(target, vim.api.nvim_get_current_tabpage())
  end)

  it("ignores cancellation and tabs closed while the picker was open", function()
    local other = new_tab "beta.lua"
    vim.api.nvim_set_current_tabpage(original_tab)
    tabs.pick()
    selection.choose(nil)
    assert.equals(original_tab, vim.api.nvim_get_current_tabpage())
    close_tab(other)
    assert.has_no.errors(function() selection.choose(selection.items[2]) end)
    assert.equals(original_tab, vim.api.nvim_get_current_tabpage())
  end)

  it("tracks ordinary tab switches and picker choices, and alternates the last two tabs", function()
    local second = new_tab "beta.lua"
    local third = new_tab "gamma.lua"
    vim.cmd "tabfirst"
    vim.cmd "tabnext"
    tabs.previous()
    assert.equals(original_tab, vim.api.nvim_get_current_tabpage())
    tabs.previous()
    assert.equals(second, vim.api.nvim_get_current_tabpage())
    tabs.pick()
    selection.choose(selection.items[3])
    assert.equals(third, vim.api.nvim_get_current_tabpage())
    tabs.previous()
    assert.equals(second, vim.api.nvim_get_current_tabpage())
  end)

  it("falls back to an older visited tab when the most recent tab has closed", function()
    local closed = new_tab "beta.lua"
    local current = new_tab "gamma.lua"
    close_tab(closed)
    assert.equals(current, vim.api.nvim_get_current_tabpage())
    tabs.previous()
    assert.equals(original_tab, vim.api.nvim_get_current_tabpage())
    tabs.previous()
    assert.equals(current, vim.api.nvim_get_current_tabpage())
  end)

  it("leaves the current tab alone when there is no previous visit", function()
    local message
    vim.notify = function(text) message = text end
    tabs.previous()
    assert.equals(original_tab, vim.api.nvim_get_current_tabpage())
    assert.equals("No previously visited tab", message)
  end)
end)
