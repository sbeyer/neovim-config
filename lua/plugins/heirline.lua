---@type LazySpec
return {
  "rebelot/heirline.nvim",
  ---@param opts table
  opts = function(_, opts)
    -- Add a mode label and tab count to the left; keep the other v6 components unchanged.
    opts.statusline[1] = require("astroui.status").component.mode {
      -- Use the theme's statusline background as contrasting text on the mode color.
      hl = { fg = "bg", bold = true },
      mode_text = { padding = { left = 1, right = 1 } },
    }
    table.insert(opts.statusline, 2, {
      condition = function() return #vim.api.nvim_list_tabpages() > 1 end,
      provider = function() return ("%d/%d "):format(vim.fn.tabpagenr(), #vim.api.nvim_list_tabpages()) end,
    })
  end,
}
