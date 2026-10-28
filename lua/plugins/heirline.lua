---@type LazySpec
return {
  "rebelot/heirline.nvim",
  ---@param opts table
  opts = function(_, opts)
    -- Add a mode label to the left; keep the rest of the v6 statusline unchanged.
    opts.statusline[1] = require("astroui.status").component.mode {
      -- Use the theme's statusline background as contrasting text on the mode color.
      hl = { fg = "bg", bold = true },
      mode_text = { padding = { left = 1, right = 1 } },
    }
  end,
}
