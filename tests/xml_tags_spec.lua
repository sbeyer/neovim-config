local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "AstroNvim", "astrocore", "nvim-ts-autotag" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
require("astrocore").setup {
  features = { notifications = false },
  filetypes = dofile("lua/plugins/astrocore.lua").opts.filetypes,
}
local spec = dofile "lua/plugins/ts-autotag.lua"
spec.init()
local defaults = require("astronvim.plugins.ts-autotag").opts
require("nvim-ts-autotag").setup(vim.tbl_deep_extend("force", defaults, spec.opts))

local buffer

local function open(extension)
  buffer = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buffer)
  vim.api.nvim_buf_set_name(buffer, vim.fn.tempname() .. "." .. extension)
  vim.bo.filetype = vim.filetype.match { buf = buffer }
end

local function type_keys(keys) vim.fn.feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "xt") end

describe("Native XML and XSD tag completion", function()
  before_each(function() buffer = nil end)

  after_each(function()
    type_keys "<Esc>"
    if buffer then vim.api.nvim_buf_delete(buffer, { force = true }) end
  end)

  for _, extension in ipairs { "xml", "xsd" } do
    it("closes tags in " .. extension .. " files without using the HTML filetype", function()
      open(extension)
      assert.equals(extension, vim.bo.filetype)
      type_keys "i<foo><Esc>"
      assert.equals("<foo></foo>", vim.api.nvim_get_current_line())
    end)
  end

  it("supports namespaced XSD tags without adding closing tags to self-closing elements", function()
    open "xsd"
    type_keys "i<xs:element><Esc>"
    assert.equals("<xs:element></xs:element>", vim.api.nvim_get_current_line())
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    type_keys "i<xs:element/><Esc>"
    assert.equals("<xs:element/>", vim.api.nvim_get_current_line())
  end)
end)
