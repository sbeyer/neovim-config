-- Test theme-aware highlights without loading AstroNvim or changing real highlights.
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

local function luminance(color)
  local result = 0
  for index, shift in ipairs { 16, 8, 0 } do
    local channel = (math.floor(color / 2 ^ shift) % 256) / 255
    channel = channel <= 0.04045 and channel / 12.92 or ((channel + 0.055) / 1.055) ^ 2.4
    result = result + channel * ({ 0.2126, 0.7152, 0.0722 })[index]
  end
  return result
end

local function contrast(first, second)
  local a, b = luminance(first), luminance(second)
  return (math.max(a, b) + 0.05) / (math.min(a, b) + 0.05)
end

describe("Theme-aware styling", function()
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

  for _, background in ipairs { "dark", "light" } do
    it("makes inline diffs readable on " .. background .. " themes without changing whole-line colors", function()
      vim.o.background = background
      colors.Normal = background == "dark" and { bg = 0x102030, fg = 0xB0C0D0 } or { bg = 0xF0F0F0, fg = 0x505050 }
      colors.DiffChange = { bg = colors.Normal.bg }
      for _, group in ipairs { "DiffText", "DiffTextAdd", "DiffTextDelete" } do
        colors[group] = { bg = colors.Normal.bg, fg = colors.Normal.fg, italic = true }
      end

      local overrides = highlights()
      for _, group in ipairs { "DiffText", "DiffTextAdd", "DiffTextDelete" } do
        assert.is_true(contrast(overrides[group].bg, colors.DiffChange.bg) > (background == "dark" and 1.5 or 1.2))
        assert.is_true(contrast(overrides[group].fg, overrides[group].bg) >= 4.5)
        assert.is_true(overrides[group].bold)
        assert.is_true(overrides[group].italic)
        assert.is_not_nil(overrides[group].ctermbg)
        assert.is_not_nil(overrides[group].ctermfg)
      end
      assert.is_not.equals(overrides.DiffText.bg, overrides.DiffTextAdd.bg)
      local red = overrides.DiffTextDelete.bg
      local green = overrides.DiffTextAdd.bg
      assert.is_true(math.floor(red / 65536) > math.floor(red / 256) % 256)
      assert.is_true(math.floor(green / 256) % 256 > math.floor(green / 65536))
      for _, group in ipairs { "DiffAdd", "DiffChange", "DiffDelete" } do
        assert.is_nil(overrides[group])
      end
    end)
  end

  it("refreshes inline diff colors after theme changes, including transparent themes", function()
    colors.Normal = {}
    local dark = highlights()
    vim.o.background = "light"
    local light = highlights()
    for _, group in ipairs { "DiffText", "DiffTextAdd", "DiffTextDelete" } do
      assert.is_not.equals(dark[group].bg, light[group].bg)
      assert.is_not.equals(dark[group].fg, light[group].fg)
      assert.is_true(contrast(dark[group].fg, dark[group].bg) >= 4.5)
      assert.is_true(contrast(light[group].fg, light[group].bg) >= 4.5)
    end
  end)
end)
