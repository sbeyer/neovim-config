---@type LazySpec
return {
  "rebelot/heirline.nvim",
  ---@param opts table
  opts = function(_, opts)
    local status = require "astroui.status"
    -- Tab information is shown in the statusline instead.
    opts.tabline = {}

    local signs = {}
    local function buffer_signs(bufnr)
      if signs[bufnr] then return signs[bufnr] end
      local git_namespaces = {}
      for name, namespace in pairs(vim.api.nvim_get_namespaces()) do
        if vim.startswith(name, "gitsigns_signs_") then git_namespaces[namespace] = true end
      end
      local columns = { git = {}, diagnostic = {} }
      for _, mark in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, { details = true, type = "sign" })) do
        local sign = mark[4]
        if sign.sign_text and vim.trim(sign.sign_text) ~= "" then
          -- Keep non-Git signs (including breakpoints) in the diagnostic slot.
          local column = git_namespaces[sign.ns_id] and columns.git or columns.diagnostic
          local line = mark[2] + 1
          if not column[line] or (sign.priority or 0) > (column[line].priority or 0) then column[line] = sign end
        end
      end
      signs[bufnr] = columns
      return columns
    end

    vim.api.nvim_set_decoration_provider(vim.api.nvim_create_namespace "user_statuscolumn", {
      -- Collect signs once per buffer per redraw, not once per displayed line.
      on_start = function() signs = {} end,
      on_win = function(_, winid, bufnr)
        if not vim.wo[winid].statuscolumn:find("eval_statuscolumn", 1, true) then return end
        local dynamic = vim.g.dynamic_statuscolumn ~= false
        local folds = dynamic and "auto:1" or "1"
        if vim.wo[winid].foldcolumn ~= "0" and vim.wo[winid].foldcolumn ~= folds then
          vim.wo[winid].foldcolumn = folds
        end
        if vim.wo[winid].signcolumn == "no" then return end
        local columns = buffer_signs(bufnr)
        -- Native width must match both dedicated slots, even on different lines.
        local width = (not dynamic or next(columns.git) and next(columns.diagnostic)) and "yes:2" or "auto:1"
        if vim.wo[winid].signcolumn ~= width then vim.wo[winid].signcolumn = width end
      end,
    })

    local function signcolumn(kind)
      local component = status.component.signcolumn {
        condition = function(self)
          return vim.wo.signcolumn ~= "no"
            and (vim.g.dynamic_statuscolumn == false or next(self.gutter_signs[kind]) ~= nil)
        end,
      }
      component[1] = {
        provider = function(self)
          local sign = vim.v.virtnum == 0 and self.gutter_signs[kind][vim.v.lnum]
          local text = sign and sign.sign_text or ""
          return text:gsub("%%", "%%%%") .. string.rep(" ", math.max(0, 2 - vim.fn.strdisplaywidth(text)))
        end,
        hl = function(self)
          local sign = self.gutter_signs[kind][vim.v.lnum]
          return sign and sign.sign_hl_group or "SignColumn"
        end,
      }
      return component
    end

    -- Left gutter: fold markers, signs, then right-aligned line numbers.
    opts.statuscolumn = {
      hl = function()
        -- Keep sign foregrounds, but use one background across all gutter components.
        return { bg = vim.api.nvim_get_hl(0, { name = "SignColumn", link = false }).bg, force = true }
      end,
      init = function(self)
        self.bufnr = vim.api.nvim_get_current_buf()
        self.gutter_signs = buffer_signs(self.bufnr)
      end,
      status.component.foldcolumn { foldcolumn = { padding = { right = 0 } } },
      signcolumn "git",
      signcolumn "diagnostic",
      status.component.fill { update = false },
      status.component.numbercolumn(),
    }

    -- Bottom bar: mode, tabs, Git, language tooling, and navigation.
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

    -- Window header: file details and breadcrumbs for the active window.
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
        hl = function() return status.hl.get_attributes(status.condition.is_active() and "winbar" or "winbarnc", true) end,
        {
          provider = status.provider.file_icon { padding = { left = 1 } },
          hl = function(self) return status.condition.is_active() and status.hl.filetype_color(self) or {} end,
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
