local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

vim.opt.rtp:append(vim.fs.joinpath(vim.fn.stdpath "data", "lazy", "astrocore"))
local core_opts = dofile("lua/plugins/astrocore.lua").opts
require("astrocore").setup {
  features = { notifications = false },
  autocmds = { hybrid_diagnostics = core_opts.autocmds.hybrid_diagnostics },
}

local namespace = vim.api.nvim_create_namespace "diagnostic_display_tests"
local buffer, cycle, original_config

local function rows(key)
  local ns = vim.diagnostic.get_namespace(namespace).user_data[key]
  local result = {}
  if ns then
    for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(buffer, ns, 0, -1, {})) do
      result[#result + 1] = mark[2] + 1
    end
  end
  return result
end

local function display() return { text = rows "virt_text_ns", lines = rows "virt_lines_ns" } end

local function move(line)
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
end

local function flush()
  local done = false
  vim.schedule(function() done = true end)
  assert(vim.wait(1000, function() return done end))
end

describe("Diagnostic display", function()
  before_each(function()
    original_config = vim.deepcopy(vim.diagnostic.config())
    local opts = dofile("lua/plugins/astrocore.lua").opts
    cycle = opts.mappings.n["<Leader>uv"][1]
    buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "first", "second", "no diagnostics" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    vim.diagnostic.config { virtual_text = false, virtual_lines = false }
    vim.diagnostic.config(vim.deepcopy(opts.diagnostics))
    vim.diagnostic.set(namespace, buffer, {
      { lnum = 0, col = 0, message = "first error", severity = vim.diagnostic.severity.ERROR },
      { lnum = 1, col = 0, message = "second warning", severity = vim.diagnostic.severity.WARN },
    })
  end)

  after_each(function()
    vim.diagnostic.reset(namespace)
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.diagnostic.config { virtual_text = false, virtual_lines = false }
    vim.diagnostic.config(original_config)
  end)

  it("defaults to inline diagnostics except on the cursor line, and follows cursor movement", function()
    assert.same({ text = { 2 }, lines = { 1 } }, display())
    move(2)
    assert.same({ text = { 1 }, lines = { 2 } }, display())
    move(3)
    assert.same({ text = { 1, 2 }, lines = {} }, display())
  end)

  it("keeps the cursor line free of inline diagnostics after replacing or deleting lines", function()
    move(2)
    vim.api.nvim_buf_set_lines(buffer, 0, 1, false, { "first changed" })
    vim.api.nvim_exec_autocmds("TextChanged", { modeline = false })
    flush()
    assert.same({ text = {}, lines = { 2 } }, display())
    vim.api.nvim_buf_set_lines(buffer, 0, 1, false, {})
    vim.api.nvim_exec_autocmds("InsertLeave", { modeline = false })
    flush()
    assert.same({}, rows "virt_text_ns")
    assert.equals(1, #rows "virt_lines_ns")
  end)

  it("restores cursor-aware diagnostics when returning to a buffer updated in the background", function()
    move(2)
    local other = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(other)
    vim.diagnostic.show(namespace, buffer)
    vim.api.nvim_set_current_buf(buffer)
    vim.api.nvim_buf_delete(other, { force = true })
    flush()
    assert.same({ text = { 1 }, lines = { 2 } }, display())
  end)

  it("cycles hybrid, all virtual lines, all virtual text, off, and back without hiding signs", function()
    cycle()
    assert.same({ text = {}, lines = { 1, 2 } }, display())
    move(2)
    assert.same({ text = {}, lines = { 1, 2 } }, display())
    cycle()
    assert.same({ text = { 1, 2 }, lines = {} }, display())
    move(1)
    assert.same({ text = { 1, 2 }, lines = {} }, display())
    cycle()
    assert.same({ text = {}, lines = {} }, display())
    assert.equals(2, #vim.diagnostic.get(buffer))
    assert.is_true(vim.diagnostic.is_enabled { bufnr = buffer })
    assert.is_true(vim.diagnostic.config().underline)
    assert.equals(2, #vim.api.nvim_buf_get_extmarks(buffer, -1, 0, -1, { type = "sign" }))
    cycle()
    assert.same({ text = { 2 }, lines = { 1 } }, display())
  end)

  it("preserves diagnostic formatting options through the whole cycle", function()
    local format = function(diagnostic) return "detail: " .. diagnostic.message end
    vim.diagnostic.config {
      virtual_text = { prefix = ">", spacing = 3, source = true },
      virtual_lines = { format = format },
    }
    for _ = 1, 4 do
      cycle()
      local config = vim.diagnostic.config()
      if config.virtual_text then
        assert.equals(">", config.virtual_text.prefix)
        assert.equals(3, config.virtual_text.spacing)
        assert.is_true(config.virtual_text.source)
      end
      if config.virtual_lines then assert.equals(format, config.virtual_lines.format) end
    end
  end)
end)
