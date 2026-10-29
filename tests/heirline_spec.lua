-- Test visible Heirline text with real AstroUI components, without checking colors.
-- Run with: ./tests/run.sh

local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "AstroNvim", "astrocore", "astroui", "heirline.nvim" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
local defaults = {}
require("astronvim.plugins._astroui_status").opts(nil, defaults)
local ui = require "astroui"
ui.config = vim.tbl_deep_extend("force", ui.config, dofile("lua/plugins/astroui.lua").opts(nil, defaults))
local status = require "astroui.status"
local heirline = require "heirline"
local mode, active, temporary, buffer, options
local original_mode, original_active, original_aerial, original_dynamic
local sign_namespace = vim.api.nvim_create_namespace "gitsigns_signs_heirline_tests"
local diagnostic_namespace = vim.api.nvim_create_namespace "heirline_diagnostic_tests"

local function gutter_width()
  vim.cmd "redraw!"
  return vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].textoff
end

local function render(kind, winid, line)
  return vim.api.nvim_eval_statusline(vim.o[kind], {
    winid = winid or vim.api.nvim_get_current_win(),
    maxwidth = 180,
    use_winbar = kind == "winbar",
    use_tabline = kind == "tabline",
    use_statuscol_lnum = line,
  }).str
end

local function setup()
  options = { opts = { colors = ui.config.status.setup_colors() } }
  dofile("lua/plugins/heirline.lua").opts(nil, options)
  heirline.setup(options)
end

describe("Heirline", function()
  before_each(function()
    vim.cmd "silent tabonly!"
    vim.cmd "silent only!"
    temporary = vim.fn.tempname() .. "-heirline-tests"
    vim.fn.mkdir(vim.fs.joinpath(temporary, "Source"), "p")
    buffer = vim.api.nvim_create_buf(false, false)
    vim.api.nvim_win_set_buf(0, buffer)
    vim.api.nvim_buf_set_name(buffer, vim.fs.joinpath(temporary, "Source", "example.cpp"))
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "int example;", "int second;", "int third;" })
    vim.bo[buffer].filetype = "cpp"
    vim.bo[buffer].modified = false
    local core_options = dofile("lua/plugins/astrocore.lua").opts.options
    original_dynamic = vim.g.dynamic_statuscolumn
    vim.g.dynamic_statuscolumn = core_options.g.dynamic_statuscolumn
    local core = core_options.opt
    vim.o.showtabline = core.showtabline
    vim.wo.signcolumn = core.signcolumn
    vim.wo.number = true
    vim.wo.relativenumber = false
    vim.wo.foldcolumn = core.foldcolumn
    vim.wo.foldmethod = "manual"
    vim.wo.fillchars = "foldopen:-,foldclose:+,foldsep:|"
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.diagnostic.config({
      signs = { text = { [vim.diagnostic.severity.ERROR] = "D" } },
      virtual_text = false,
      virtual_lines = false,
      underline = false,
    }, diagnostic_namespace)
    original_mode, original_active, original_aerial = vim.fn.mode, status.condition.is_active, package.loaded.aerial
    mode, active = "n", vim.api.nvim_get_current_win()
    vim.fn.mode = function() return mode end
    status.condition.is_active = function() return vim.api.nvim_get_current_win() == active end
    package.loaded.aerial = nil
    setup()
  end)

  after_each(function()
    vim.fn.mode, status.condition.is_active, package.loaded.aerial = original_mode, original_active, original_aerial
    vim.g.dynamic_statuscolumn = original_dynamic
    vim.diagnostic.reset(diagnostic_namespace)
    vim.cmd "silent tabonly!"
    vim.cmd "silent only!"
    if vim.api.nvim_buf_is_valid(buffer) then vim.api.nvim_buf_delete(buffer, { force = true }) end
    vim.fn.delete(temporary, "rf")
  end)

  it("shows three-letter mode names without shifting the Git branch", function()
    vim.b[buffer].gitsigns_head = "feature/example"
    local branch_column
    for key in pairs(ui.config.status.modes) do
      mode = key
      setup()
      local text = render "statusline"
      local label = assert(text:match "^ (%u%u%u) ")
      assert.equals(3, #label)
      local column = assert(text:find("feature/example", 1, true))
      branch_column = branch_column or column
      assert.equals(branch_column, column)
    end
    for key, label in pairs { n = "NOR", i = "INS", c = "CMD", v = "VIS", V = "LIN", ["\22"] = "BLK" } do
      mode = key
      setup()
      assert(render("statusline"):find(" " .. label .. " ", 1, true))
    end
  end)

  it("shows tab numbers in the statusline instead of a tabline", function()
    assert.is_nil(render("statusline"):find("1/1", 1, true))
    vim.cmd "tabnew"
    assert(render("statusline"):find("2/2", 1, true))
    assert.equals("", render "tabline")
    assert.equals(0, vim.o.showtabline)
    vim.cmd "tabprevious"
    assert(render("statusline"):find("1/2", 1, true))
    assert.equals("", render "tabline")
  end)

  it("shows fold markers and two signs before the line number", function()
    vim.cmd "1,2fold"
    vim.api.nvim_buf_set_extmark(buffer, sign_namespace, 0, 0, { sign_text = "G", priority = 10 })
    vim.diagnostic.set(diagnostic_namespace, buffer, { { lnum = 0, col = 0, message = "example error" } })
    gutter_width()
    local text = render("statuscolumn", nil, 1)
    local fold = assert(text:find("+", 1, true))
    local git = assert(text:find("G", 1, true))
    local diagnostic = assert(text:find("D", 1, true))
    local number = assert(text:find("1", 1, true))
    assert(fold < git and fold < diagnostic and git < number and diagnostic < number)
    assert(text:match "1%s*$")
  end)

  it("adds and removes independent Git and diagnostic columns, even on different lines", function()
    vim.bo[buffer].filetype = "text"
    local numbers_only = gutter_width()
    assert.equals(vim.wo.numberwidth, numbers_only)
    local git = vim.api.nvim_buf_set_extmark(buffer, sign_namespace, 0, 0, { sign_text = "G", priority = 10 })
    assert.equals(numbers_only + 2, gutter_width())
    assert(render("statuscolumn", nil, 1):find("G", 1, true))
    vim.diagnostic.set(diagnostic_namespace, buffer, { { lnum = 1, col = 0, message = "example error" } })
    assert.equals(numbers_only + 4, gutter_width())
    assert(render("statuscolumn", nil, 2):find("D", 1, true))
    vim.api.nvim_buf_del_extmark(buffer, sign_namespace, git)
    assert.equals(numbers_only + 2, gutter_width())
    assert.is_nil(render("statuscolumn", nil, 1):find("G", 1, true))
    assert(render("statuscolumn", nil, 2):find("D", 1, true))
    vim.diagnostic.reset(diagnostic_namespace, buffer)
    assert.equals(numbers_only, gutter_width())
    assert(render("statuscolumn", nil, 1):match "^%s*1%s*$")
  end)

  it("adds the fold column for open or closed folds and removes it when the last fold is deleted", function()
    local numbers_only = gutter_width()
    vim.cmd "1,2fold"
    assert.equals(numbers_only + 1, gutter_width())
    assert(render("statuscolumn", nil, 1):find("+", 1, true))
    vim.cmd "normal! zo"
    assert.equals(numbers_only + 1, gutter_width())
    local opened = render("statuscolumn", nil, 1)
    assert(opened:find("|", 1, true), vim.inspect(opened))
    vim.cmd "normal! zE"
    assert.equals(numbers_only, gutter_width())
    assert(render("statuscolumn", nil, 1):match "^%s*1%s*$")
  end)

  it("toggles fixed and dynamic gutter widths in all visible windows through the UI mapping", function()
    local toggle = dofile("lua/plugins/astrocore.lua").opts.mappings.n["<Leader>u<"][1]
    local numbers_only = gutter_width()
    local first = vim.api.nvim_get_current_win()
    vim.cmd "vsplit"
    toggle()
    assert.equals(numbers_only + 5, gutter_width())
    assert.equals(numbers_only + 5, vim.fn.getwininfo(first)[1].textoff)
    local git = vim.api.nvim_buf_set_extmark(buffer, sign_namespace, 0, 0, { sign_text = "G", priority = 10 })
    assert.equals(numbers_only + 5, gutter_width())
    assert(render("statuscolumn", nil, 1):find("G", 1, true))
    vim.api.nvim_buf_del_extmark(buffer, sign_namespace, git)
    assert.equals(numbers_only + 5, gutter_width())
    toggle()
    assert.equals(numbers_only, gutter_width())
    assert.equals(numbers_only, vim.fn.getwininfo(first)[1].textoff)
    vim.api.nvim_buf_set_extmark(buffer, sign_namespace, 0, 0, { sign_text = "G", priority = 10 })
    assert.equals(numbers_only + 2, gutter_width())
    assert(render("statuscolumn", nil, 1):find("G", 1, true))
  end)

  it("shows read-only and modified markers in the winbar, with only necessary filetype labels", function()
    vim.bo[buffer].readonly = true
    vim.bo[buffer].modified = true
    local text = render "winbar"
    assert(text:find("example.cpp", 1, true))
    assert(text:find("[RO] ●", 1, true))
    assert.is_nil(text:find("[cpp]", 1, true))
    vim.api.nvim_buf_set_name(buffer, vim.fs.joinpath(temporary, "Source", "example.hpp"))
    assert(render("winbar"):find("[cpp]", 1, true))
    local statusline = render "statusline"
    assert.is_nil(statusline:find("[RO]", 1, true))
    assert.is_nil(statusline:find("●", 1, true))
  end)

  it("shows breadcrumbs only in the active winbar and the file path in inactive windows", function()
    package.loaded.aerial =
      { get_location = function() return { { name = "example_function", kind = "Function", lnum = 1, col = 0 } } end }
    assert(render("winbar"):find("example_function", 1, true))
    local first = vim.api.nvim_get_current_win()
    vim.cmd "vsplit"
    active = vim.api.nvim_get_current_win()
    local inactive = render("winbar", first)
    assert(inactive:find("Source/example.cpp", 1, true))
    assert.is_nil(inactive:find("example_function", 1, true))
    assert(render("winbar"):find("example_function", 1, true))
  end)
end)
