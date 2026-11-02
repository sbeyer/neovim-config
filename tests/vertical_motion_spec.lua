local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

vim.opt.rtp:append(vim.fn.stdpath "data" .. "/lazy/astrocore")
local mappings = { n = {}, x = {} }
for _, mode in ipairs { "n", "x" } do
  for _, key in ipairs { "j", "k" } do
    mappings[mode][key] = { ("v:count == 0 ? 'g%s' : '%s'"):format(key, key), expr = true }
  end
end
require("astrocore").setup {
  features = { notifications = false },
  mappings = vim.tbl_deep_extend("force", mappings, dofile("lua/plugins/astrocore.lua").opts.mappings),
}

local buffer, original_wrap
local function type_keys(keys) vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt") end
local function row() return vim.api.nvim_win_get_cursor(0)[1] end

describe("Native vertical motions", function()
  before_each(function()
    original_wrap = vim.wo.wrap
    vim.wo.wrap = true
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { string.rep("a", 500), string.rep("b", 500), "last line" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end)

  after_each(function()
    type_keys "<Esc>"
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.wo.wrap = original_wrap
  end)

  for _, prefix in ipairs { "", "v" } do
    it("restores native vertical motions in " .. (prefix == "" and "Normal" or "Visual") .. " mode", function()
      type_keys(prefix .. "j")
      assert.equals(2, row())
      type_keys "k"
      assert.equals(1, row())
      type_keys "gj"
      assert.equals(1, row())
      assert(vim.api.nvim_win_get_cursor(0)[2] > 0)
      type_keys "gk"
      assert.same({ 1, 0 }, vim.api.nvim_win_get_cursor(0))
      type_keys "2j"
      assert.equals(3, row())
      type_keys "2k"
      assert.equals(1, row())
    end)
  end
end)
