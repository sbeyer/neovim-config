local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "nvim-spider" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
local specs = dofile "lua/plugins/motion.lua"
require("astrocore").setup {
  features = { notifications = false },
  mappings = specs[1].opts.mappings,
}
require("spider").setup(specs[2].opts)
for _, key in ipairs(specs[2].keys) do
  vim.keymap.set(key.mode, key[1], key[2], { desc = key.desc })
end

local buffer, original_timeout, original_timeoutlen

local function type_keys(keys) vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt") end

local function column() return vim.api.nvim_win_get_cursor(0)[2] end

local function line() return vim.api.nvim_get_current_line() end

describe("Prefixed subword motions", function()
  before_each(function()
    original_timeout, original_timeoutlen = vim.o.timeout, vim.o.timeoutlen
    vim.o.timeout, vim.o.timeoutlen = true, 20
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "snake_case camelCase PascalCase HTTPServer tail" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end)

  after_each(function()
    type_keys "<Esc>"
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.o.timeout, vim.o.timeoutlen = original_timeout, original_timeoutlen
  end)

  it("moves through snake, camel, Pascal and acronym boundaries with counts", function()
    type_keys "_w"
    assert.equals(6, column())
    type_keys "2_w"
    assert.equals(16, column())
    type_keys "2_w"
    assert.equals(27, column())
    type_keys "2_w"
    assert.equals(36, column())
    type_keys "_b"
    assert.equals(32, column())
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    type_keys "_e"
    assert.equals(4, column())
  end)

  it("leaves native word motions unchanged", function()
    type_keys "w"
    assert.equals(11, column())
    type_keys "e"
    assert.equals(19, column())
    type_keys "b"
    assert.equals(11, column())
  end)

  it("supports visual selection and inclusive subword ends", function()
    type_keys "v_ed"
    assert.equals("_case camelCase PascalCase HTTPServer tail", line())
  end)

  it("supports operators and dot-repeat", function()
    type_keys "d_w"
    assert.equals("case camelCase PascalCase HTTPServer tail", line())
    type_keys "."
    assert.equals("camelCase PascalCase HTTPServer tail", line())
  end)

  it("does not move when a standalone prefix times out", function()
    vim.api.nvim_win_set_cursor(0, { 1, 8 })
    type_keys "_"
    assert.equals(8, column())
    assert.equals("n", vim.api.nvim_get_mode().mode)
  end)

  it("cancels a timed-out operator so a late w cannot delete text", function()
    local original = line()
    type_keys "d_"
    assert.equals("n", vim.api.nvim_get_mode().mode)
    assert.equals(original, line())
    type_keys "w"
    assert.equals(original, line())
    assert.equals(11, column())
  end)

  it("preserves the original linewise motion and its count under __", function()
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "  first", "    second", " third" })
    vim.api.nvim_win_set_cursor(0, { 1, 5 })
    type_keys "__"
    assert.same({ 1, 2 }, vim.api.nvim_win_get_cursor(0))
    type_keys "3__"
    assert.same({ 3, 1 }, vim.api.nvim_win_get_cursor(0))
    type_keys "d__"
    assert.same({ "  first", "    second" }, vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
    assert.equals("V", vim.fn.getregtype())
  end)
end)
