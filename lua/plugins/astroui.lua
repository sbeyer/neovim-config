-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@param opts AstroUIOpts
  opts = function(_, opts)
    -- Keep every mode label three columns wide without changing its theme color.
    local mode_names = {
      NORMAL = "NOR",
      INSERT = "INS",
      COMMAND = "CMD",
      VISUAL = "VIS",
      LINES = "LIN",
      BLOCK = "BLK",
      REPLACE = "REP",
      ["V-REPLACE"] = "VRP",
      SELECT = "SEL",
      TERM = "TRM",
      OP = "OPR",
      PROMPT = "PRM",
      MORE = "MOR",
      CONFIRM = "CNF",
      SHELL = "SHL",
      null = "NUL",
    }
    for _, mode in pairs(opts.status.modes) do
      mode[1] = mode_names[mode[1]] or mode[1]:sub(1, 3):upper()
    end
    return vim.tbl_deep_extend("force", opts, {
      folding = {
        -- Avoid constructing expensive fold trees before AstroLargeBuf fires.
        enabled = function(buf)
          local buffer = require "astrocore.buffer"
          return buffer.is_valid(buf) and not buffer.is_large(buf)
        end,
      },
      -- change colorscheme
      colorscheme = "astrodark",
      -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
      highlights = {
        -- Recompute annotation and gutter backgrounds after every colorscheme change.
        init = function()
          local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
          local dark = vim.o.background == "dark"
          local background = normal.bg or (dark and 0x202020 or 0xFFFFFF)
          local foreground = normal.fg or (dark and 0xFFFFFF or 0x000000)
          local annotation_background, gutter_background = 0, 0
          for _, shift in ipairs { 16, 8, 0 } do
            local base = math.floor(background / 2 ^ shift) % 256
            local target = math.floor(foreground / 2 ^ shift) % 256
            annotation_background = annotation_background + math.floor(base + (target - base) * 0.08 + 0.5) * 2 ^ shift
            gutter_background = gutter_background + math.floor(base * 0.5 + 0.5) * 2 ^ shift
          end

          local highlights = {
            -- Normal = { bg = "#000000" },
          }
          for _, group in ipairs {
            "SignColumn",
            "CursorLineSign",
            "FoldColumn",
            "CursorLineFold",
            "LineNr",
            "LineNrAbove",
            "LineNrBelow",
            "CursorLineNr",
          } do
            highlights[group] = vim.api.nvim_get_hl(0, { name = group, link = false })
            highlights[group].bg = gutter_background
          end
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
    })
  end,
}
