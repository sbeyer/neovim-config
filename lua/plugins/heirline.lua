---@type LazySpec
return {
  "rebelot/heirline.nvim",
  ---@param opts table
  opts = function(_, opts)
    local status = require "astroui.status"
    -- Add a mode label and tab count, and move file details to the winbar.
    opts.statusline[1] = status.component.mode {
      -- Use the theme's statusline background as contrasting text on the mode color.
      hl = { fg = "bg", bold = true },
      mode_text = { padding = { left = 1, right = 1 } },
      surround = { separator = { "", " " } },
    }
    opts.statusline[2] = status.component.git_branch {
      git_branch = { icon = { kind = "NONE" } },
      surround = { separator = { "", " " } },
    }
    opts.statusline[3] = status.component.file_info { file_icon = false, file_modified = false, filetype = false }
    opts.statusline[4] = status.component.git_diff {
      added = { icon = { padding = { left = 0, right = 1 } }, padding = { right = 1 } },
      changed = { icon = { padding = { left = 0, right = 1 } }, padding = { right = 1 } },
      removed = { icon = { padding = { left = 0, right = 1 } }, padding = { right = 1 } },
      surround = { separator = { "", " " } },
    }
    -- Keep Git changes beside the branch, moving file information after both.
    opts.statusline[3], opts.statusline[4] = opts.statusline[4], opts.statusline[3]
    -- Remove the default virtual environment indicator.
    table.remove(opts.statusline, 10)
    -- Show the current tab number and total only when multiple tabs are open.
    table.insert(opts.statusline, 2, {
      condition = function() return #vim.api.nvim_list_tabpages() > 1 end,
      provider = function() return ("%d/%d "):format(vim.fn.tabpagenr(), #vim.api.nvim_list_tabpages()) end,
    })

    local function show_filetype(self)
      local filetype = vim.bo[self.bufnr].filetype
      -- Only label active files when their name does not already end in .<filetype>.
      return status.condition.is_active()
        and filetype ~= ""
        and not vim.endswith(vim.api.nvim_buf_get_name(self.bufnr), "." .. filetype)
    end

    opts.winbar = {
      init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
      fallthrough = false,
      {
        -- Show filename + breadcrumbs only in the active window with a nonempty Aerial location;
        -- otherwise fall back to the relative path below, including when Aerial is not loaded.
        condition = function()
          return status.condition.is_active()
            and status.condition.aerial_available()
            and not vim.tbl_isempty(require("aerial").get_location(true) or {})
        end,
        hl = function() return status.hl.get_attributes("winbar", true) end,
        {
          provider = status.provider.file_icon { padding = { left = 1 } },
          hl = status.hl.filetype_color,
        },
        { provider = "%<" },
        { provider = status.provider.filename { padding = { left = 1 } }, hl = { bold = true } },
        {
          provider = status.provider.file_modified {
            str = "●",
            icon = { kind = "NONE" },
            show_empty = false,
            padding = { left = 1 },
          },
        },
        {
          condition = show_filetype,
          provider = status.provider.filetype { separator = { left = " [", right = "]" } },
        },
        status.component.breadcrumbs { prefix = true, padding = { left = 0 } },
      },
      {
        hl = function()
          return status.hl.get_attributes(status.condition.is_active() and "winbar" or "winbarnc", true)
        end,
        {
          provider = status.provider.file_icon { padding = { left = 1 } },
          hl = function(self)
            return status.condition.is_active() and status.hl.filetype_color(self) or {}
          end,
        },
        -- Use a CWD-relative path, truncating from the left when it does not fit.
        { provider = "%<" },
        {
          provider = status.provider.filename { modify = ":.", padding = { left = 1 } },
          hl = function() return { bold = status.condition.is_active() } end,
        },
        {
          provider = status.provider.file_modified {
            str = "●",
            icon = { kind = "NONE" },
            show_empty = false,
            padding = { left = 1 },
          },
        },
        {
          condition = show_filetype,
          provider = status.provider.filetype { separator = { left = " [", right = "]" } },
        },
      },
    }
  end,
}
