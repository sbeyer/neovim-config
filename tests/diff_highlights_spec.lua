local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each
local highlights = require "diff_highlights"
local autocmds = dofile("lua/plugins/astrocore.lua").opts.autocmds.directional_inline_diff
local group = vim.api.nvim_create_augroup("DirectionalDiffTest", { clear = true })
for _, autocmd in ipairs(autocmds) do
  vim.api.nvim_create_autocmd(autocmd.event, { group = group, pattern = autocmd.pattern, callback = autocmd.callback })
end
local left, right

local function flush()
  local done = false
  vim.schedule(function() done = true end)
  assert(vim.wait(1000, function() return done end))
end

local function mapping(win) return vim.wo[win].winhighlight:match "DiffTextAdd:([^,]+)" end

local function disable_diff()
  vim.cmd "diffoff!"
  -- OptionSet is suppressed during startup, when the headless harness runs these tests.
  vim.api.nvim_exec_autocmds("OptionSet", { pattern = "diff" })
  flush()
end

describe("Directional inline diff highlights", function()
  before_each(function()
    vim.cmd "silent only!"
    left = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first prefix removed suffix", "second prefix suffix" })
    vim.wo.winhighlight = "Normal:Normal,DiffTextAdd:DiffText"
    vim.cmd "diffthis"
    vim.cmd "rightbelow vnew"
    right = vim.api.nvim_get_current_win()
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first prefix suffix", "second prefix added suffix" })
    vim.wo.winhighlight = ""
    vim.cmd "diffthis"
    vim.cmd "diffupdate"
    flush()
  end)

  after_each(function()
    disable_diff()
    vim.cmd "silent only!"
    vim.wo.winhighlight = ""
    highlights.update()
  end)

  it("uses red for left-only text and keeps right-only text green", function()
    for _, pane in ipairs { { win = left, line = 1, col = 14 }, { win = right, line = 2, col = 15 } } do
      local name = vim.api.nvim_win_call(
        pane.win,
        function() return vim.fn.synIDattr(vim.fn.diff_hlID(pane.line, pane.col), "name") end
      )
      assert.equals("DiffTextAdd", name)
    end
    assert.equals("DiffTextDelete", mapping(left))
    assert.is_nil(mapping(right))
    assert(vim.wo[left].winhighlight:find("Normal:Normal", 1, true))
  end)

  it("restores existing mappings when diff mode is disabled", function()
    disable_diff()
    assert.equals("DiffText", mapping(left))
    assert.equals("Normal:Normal,DiffTextAdd:DiffText", vim.wo[left].winhighlight)
    assert.is_nil(mapping(right))
  end)

  it("follows pane positions when the windows are swapped", function()
    vim.cmd "wincmd x"
    vim.cmd "diffupdate"
    flush()
    assert.equals("DiffText", mapping(left))
    assert.equals("DiffTextDelete", mapping(right))
  end)

  it("does not assign old/new meaning to multi-way diffs", function()
    vim.cmd "rightbelow vnew"
    vim.cmd "diffthis"
    flush()
    assert.equals("DiffText", mapping(left))
    assert.is_nil(mapping(right))
    assert.is_nil(mapping(vim.api.nvim_get_current_win()))
    vim.cmd "close!"
    flush()
    assert.equals("DiffTextDelete", mapping(left))
  end)
end)
