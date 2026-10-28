---@type LazySpec
return {
  "rebelot/heirline.nvim",
  ---@param opts table
  opts = function(_, opts)
    local status = require "astroui.status"
    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },

      -- Mode information.
      status.component.mode {
        -- Use the theme's statusline background as contrasting text on the mode color.
        hl = { fg = "bg", bold = true },
        mode_text = { padding = { left = 1, right = 1 } },
        surround = { separator = { "", " " } },
      },

      -- Show the current tab number and total only when multiple tabs are open.
      {
        condition = function() return #vim.api.nvim_list_tabpages() > 1 end,
        provider = function() return ("%d/%d "):format(vim.fn.tabpagenr(), #vim.api.nvim_list_tabpages()) end,
      },

      -- Git information.
      status.component.git_branch {
        git_branch = { icon = { kind = "NONE" } },
        surround = { separator = { "", " " } },
      },
      status.component.git_diff {
        added = { icon = { padding = { left = 0, right = 1 } }, padding = { right = 1 } },
        changed = { icon = { padding = { left = 0, right = 1 } }, padding = { right = 1 } },
        removed = { icon = { padding = { left = 0, right = 1 } }, padding = { right = 1 } },
        surround = { separator = { "", " " } },
      },

      status.component.fill(),

      -- Command information.
      status.component.cmd_info(),
      status.component.fill(),

      -- Language tooling, without the default virtual environment indicator.
      status.component.diagnostics(),
      status.component.lsp(),
      status.component.treesitter(),

      -- File navigation and a matching mode color on the right.
      status.component.nav(),

      status.component.mode { surround = { separator = "right" } },
    }

    local function show_filetype(self)
      local filetype = vim.bo[self.bufnr].filetype
      -- Only label active files when their name does not already end in .<filetype>.
      return status.condition.is_active()
        and filetype ~= ""
        and not vim.endswith(vim.api.nvim_buf_get_name(self.bufnr), "." .. filetype)
    end

    local file_state = status.component.builder {
      {
        provider = status.provider.file_read_only {
          str = "[RO]",
          icon = { kind = "NONE" },
          show_empty = false,
          padding = { left = 1 },
        },
      },
      {
        provider = status.provider.file_modified {
          str = "●",
          icon = { kind = "NONE" },
          show_empty = false,
          padding = { left = 1 },
        },
      },
    }

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
        file_state,
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
        file_state,
        {
          condition = show_filetype,
          provider = status.provider.filetype { separator = { left = " [", right = "]" } },
        },
      },
    }
  end,
}
