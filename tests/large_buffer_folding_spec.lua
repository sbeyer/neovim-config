local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "astroui" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
local core = require "astrocore"
local core_opts = dofile("lua/plugins/astrocore.lua").opts
local before_manual_mode
-- Inspect the fold tree before switching to manual mode could retain expensive automatic folds.
vim.api.nvim_create_autocmd("User", {
  pattern = "AstroLargeBuf",
  callback = function()
    before_manual_mode = {
      enabled = require("astroui.folding").is_enabled(),
      method = vim.wo.foldmethod,
      level = vim.fn.foldlevel(2),
    }
  end,
})
core.setup {
  features = { large_buf = vim.tbl_extend("force", core_opts.features.large_buf, { notify = false }) },
  autocmds = { large_buffer_folding = core_opts.autocmds.large_buffer_folding },
}
local ui = require "astroui"
ui.config.folding = vim.tbl_deep_extend(
  "force",
  ui.config.folding,
  dofile("lua/plugins/astroui.lua").opts(nil, { status = { modes = {} } }).folding,
  { methods = { "indent" } }
)
local folding = require "astroui.folding"
local temporary, original_method, original_expr, original_shiftwidth

local function open_file(name, lines)
  local path = vim.fs.joinpath(temporary, name)
  vim.fn.writefile(lines, path)
  local buf = vim.fn.bufadd(path)
  vim.bo[buf].buflisted = true
  vim.cmd.buffer(buf)
  vim.cmd "redraw!"
  return vim.api.nvim_get_current_buf()
end

describe("Large-buffer folding", function()
  before_each(function()
    before_manual_mode = nil
    temporary = vim.fn.tempname() .. "-folding-tests"
    vim.fn.mkdir(temporary, "p")
    original_method, original_expr = vim.o.foldmethod, vim.o.foldexpr
    original_shiftwidth = vim.o.shiftwidth
    vim.o.foldmethod = "expr"
    vim.o.foldexpr = "v:lua.require'astroui.folding'.foldexpr()"
    vim.o.shiftwidth = 2
    vim.wo.foldlevel = 99
  end)

  after_each(function()
    vim.cmd "silent only!"
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):find(temporary, 1, true) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end
    vim.o.foldmethod, vim.o.foldexpr = original_method, original_expr
    vim.o.shiftwidth = original_shiftwidth
    vim.fn.delete(temporary, "rf")
  end)

  it("prevents automatic folds before switching to manual mode, but allows manual folds", function()
    local lines = { "int example() {" }
    for _ = 1, 10001 do
      lines[#lines + 1] = "  example();"
    end
    lines[#lines + 1] = "}"
    local buf = open_file("large.cpp", lines)
    assert.is_true(vim.b[buf].large_buf)
    assert.same({ enabled = false, method = "expr", level = 0 }, before_manual_mode)
    assert.equals("manual", vim.wo.foldmethod)
    assert.equals(0, vim.fn.foldlevel(2))
    vim.cmd "2,3fold"
    assert.equals(1, vim.fn.foldlevel(2))
  end)

  it("disables folding for size-based large files as well as line-count-based ones", function()
    local lines = {}
    for _ = 1, 3000 do
      lines[#lines + 1] = "  " .. string.rep("example(); ", 8)
    end
    local buf = open_file("size.cpp", lines)
    assert.is_true(vim.b[buf].large_buf)
    assert.is_false(folding.is_enabled(buf))
    assert.equals("manual", vim.wo.foldmethod)
  end)

  it("keeps ordinary-file folds and applies manual mode in a new window for a hidden large buffer", function()
    local large_path = vim.fs.joinpath(temporary, "hidden.cpp")
    local lines = {}
    for _ = 1, 10001 do
      lines[#lines + 1] = "  example();"
    end
    vim.fn.writefile(lines, large_path)
    local large = vim.fn.bufadd(large_path)
    vim.bo[large].buflisted = true
    vim.fn.bufload(large)
    local small = open_file("small.cpp", { "int example() {", "  example();", "}" })
    assert.is_true(folding.is_enabled(small))
    assert.equals("expr", vim.wo.foldmethod)
    assert.equals(1, vim.fn.foldlevel(2))
    vim.cmd "split"
    vim.api.nvim_win_set_buf(0, large)
    assert.equals("manual", vim.wo.foldmethod)
    assert.equals(0, vim.fn.foldlevel(2))
    vim.cmd "2,3fold"
    vim.api.nvim_win_set_buf(0, small)
    assert.equals("expr", vim.wo.foldmethod)
    assert.equals(1, vim.fn.foldlevel(2))
    vim.api.nvim_win_set_buf(0, large)
    assert.equals("manual", vim.wo.foldmethod)
    assert.equals(1, vim.fn.foldlevel(2))
  end)
end)
