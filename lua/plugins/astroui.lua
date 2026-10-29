-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "astrodark",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      -- Recompute annotation backgrounds after every colorscheme change.
      init = function()
        local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
        local dark = vim.o.background == "dark"
        local background = normal.bg or (dark and 0x202020 or 0xFFFFFF)
        local foreground = normal.fg or (dark and 0xFFFFFF or 0x000000)
        local annotation_background = 0
        for _, shift in ipairs { 16, 8, 0 } do
          local base = math.floor(background / 2 ^ shift) % 256
          local target = math.floor(foreground / 2 ^ shift) % 256
          annotation_background = annotation_background + math.floor(base + (target - base) * 0.08 + 0.5) * 2 ^ shift
        end

        local highlights = {
          -- Normal = { bg = "#000000" },
        }
        for _, group in ipairs {
          "DiagnosticVirtualTextError",
          "DiagnosticVirtualTextWarn",
          "DiagnosticVirtualTextInfo",
          "DiagnosticVirtualTextHint",
          "DiagnosticVirtualTextOk",
          "LspInlayHint",
          "LspCodeLens",
        } do
          highlights[group] = vim.api.nvim_get_hl(0, { name = group, link = false })
          highlights[group].bg = annotation_background
        end
        return highlights
      end,
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
