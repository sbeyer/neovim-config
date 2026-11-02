local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

vim.opt.rtp:append(vim.fn.stdpath "data" .. "/lazy/dial.nvim")
vim.g.mapleader = " "
local spec = dofile "lua/plugins/increment-decrement.lua"
spec.config()
for _, key in ipairs(spec.keys) do
  vim.keymap.set(key.mode or "n", key[1], key[2], { desc = key.desc })
end

local buffer

local function type_keys(keys) vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt") end

local function set_lines(lines)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function lines() return vim.api.nvim_buf_get_lines(buffer, 0, -1, false) end

describe("Smart increment and decrement", function()
  before_each(function()
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buffer)
  end)

  after_each(function()
    type_keys "<Esc>"
    vim.api.nvim_buf_delete(buffer, { force = true })
  end)

  it("toggles booleans in either direction", function()
    set_lines { "false" }
    for _, key in ipairs { "<Space><C-a>", "<Space><C-x>" } do
      type_keys(key)
      assert.same({ "true" }, lines())
      type_keys(key)
      assert.same({ "false" }, lines())
    end
  end)

  it("cycles through identifier cases and wraps in both directions", function()
    set_lines { "different_cases" }
    for _, expected in ipairs { "differentCases", "DifferentCases", "DIFFERENT_CASES", "different_cases" } do
      type_keys "<Space><C-a>"
      assert.same({ expected }, lines())
    end
    for _, expected in ipairs { "DIFFERENT_CASES", "DifferentCases", "differentCases", "different_cases" } do
      type_keys "<Space><C-x>"
      assert.same({ expected }, lines())
    end
  end)

  it("retains decimal, hexadecimal, date and semantic version rules", function()
    for _, case in ipairs {
      { "9", "10" },
      { "0xf", "0x10" },
      { "2024/02/28", "2024/02/29" },
      { "1.2.3", "1.2.4" },
    } do
      set_lines { "value: " .. case[1] }
      type_keys "<Space><C-a>"
      assert.same({ "value: " .. case[2] }, lines())
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      type_keys "<Space><C-x>"
      assert.same({ "value: " .. case[1] }, lines())
    end
  end)

  it("supports counts and dot-repeat", function()
    set_lines { "10" }
    type_keys "3<Space><C-a>"
    assert.same({ "13" }, lines())
    type_keys "."
    assert.same({ "16" }, lines())
    type_keys "2<Space><C-x>"
    assert.same({ "14" }, lines())
  end)

  it("changes all selected lines uniformly", function()
    set_lines { "1", "1", "1" }
    type_keys "Vjj<Space><C-a>"
    assert.same({ "2", "2", "2" }, lines())
    type_keys "gv<Space><C-x>"
    assert.same({ "1", "1", "1" }, lines())
  end)

  it("supports progressive changes across selected lines", function()
    set_lines { "1", "1", "1" }
    type_keys "Vjjg<Space><C-a>"
    assert.same({ "2", "3", "4" }, lines())
    type_keys "gvg<Space><C-x>"
    assert.same({ "1", "1", "1" }, lines())
  end)

  it("leaves unprefixed increment and decrement native", function()
    set_lines { "false 10" }
    type_keys "<C-a>"
    assert.same({ "false 11" }, lines())
    type_keys "<C-x>"
    assert.same({ "false 10" }, lines())
  end)
end)
