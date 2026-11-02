-- Test theme-aware annotation backgrounds without loading AstroNvim or changing real highlights.
-- Run with: ./tests/run.sh

local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

-- opts is now a function that shortens mode names; supply an empty mode table to obtain highlights without AstroNvim.
local highlights = dofile("lua/plugins/astroui.lua").opts(nil, { status = { modes = {} } }).highlights.init
local original_get_hl, original_background, colors
local groups = {
  "DiagnosticVirtualTextError",
  "DiagnosticVirtualTextWarn",
  "DiagnosticVirtualTextInfo",
  "DiagnosticVirtualTextHint",
  "DiagnosticVirtualTextOk",
  "DiagnosticVirtualLinesError",
  "DiagnosticVirtualLinesWarn",
  "DiagnosticVirtualLinesInfo",
  "DiagnosticVirtualLinesHint",
  "DiagnosticVirtualLinesOk",
  "LspInlayHint",
  "LspCodeLens",
}

describe("Virtual text styling", function()
  before_each(function()
    original_get_hl, original_background = vim.api.nvim_get_hl, vim.o.background
    vim.o.background = "dark"
    colors = { Normal = { bg = 0x102030, fg = 0xB0C0D0 } }
    for index, group in ipairs(groups) do
      colors[group] = { fg = 0x123450 + index, bg = 0x000000, italic = true }
    end
    vim.api.nvim_get_hl = function(_, opts) return vim.deepcopy(colors[opts.name] or {}) end
  end)

  after_each(function()
    vim.api.nvim_get_hl, vim.o.background = original_get_hl, original_background
  end)

  it("uses the darker eight-percent blend for diagnostics, inlay hints, and CodeLens", function()
    local overrides = highlights()
    for _, group in ipairs(groups) do
      assert.equals(0x1D2D3D, overrides[group].bg)
    end
  end)

  it("preserves each annotation's foreground and text attributes", function()
    local overrides = highlights()
    for _, group in ipairs(groups) do
      assert.equals(colors[group].fg, overrides[group].fg)
      assert.is_true(overrides[group].italic)
    end
  end)

  it("leaves Git blame, source text, signs, and underlines unchanged", function()
    local overrides = highlights()
    for _, group in ipairs {
      "GitSignsCurrentLineBlame",
      "Normal",
      "Comment",
      "DiagnosticSignError",
      "DiagnosticUnderlineError",
    } do
      assert.is_nil(overrides[group])
    end
  end)

  it("recomputes the background and foregrounds when the theme changes", function()
    local dark = highlights()
    colors.Normal = { bg = 0xF0F0F0, fg = 0x505050 }
    colors.LspInlayHint.fg = 0x101010
    vim.o.background = "light"
    local light = highlights()
    assert.equals(0xE3E3E3, light.LspInlayHint.bg)
    assert.is_not.equals(dark.LspInlayHint.bg, light.LspInlayHint.bg)
    assert.equals(0x101010, light.LspInlayHint.fg)
  end)

  it("provides a subtle background when a transparent dark theme omits Normal colors", function()
    colors.Normal = {}
    assert.equals(0x323232, highlights().LspCodeLens.bg)
  end)

  it("provides a subtle background when a transparent light theme omits Normal colors", function()
    colors.Normal = {}
    vim.o.background = "light"
    assert.equals(0xEBEBEB, highlights().LspCodeLens.bg)
  end)
end)
