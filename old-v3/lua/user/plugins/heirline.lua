return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require("astronvim.utils.status")

    -- remove tabline
    opts.tabline = {}

    -- tab information in statusline
    -- PORTED to v6: lua/plugins/heirline.lua uses current/total, hidden with only one tab.
    local tablist = status.component.builder({
      -- condition = function() return #vim.api.nvim_list_tabpages() >= 2 end,
      surround = { separator = "left" },
      status.heirline.make_tablist({
        -- component for each tab
        provider = status.provider.tabnr(),
        hl = function(self)
          return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true)
        end,
      }),
    })

    opts.statusline = {
      hl = { fg = "fg", bg = "bg" },
      -- show mode text
      -- PORTED to v6: lua/plugins/heirline.lua (left mode label only).
      status.component.mode({
        hl = { bold = true },
        mode_text = { padding = { left = 1, right = 1 } },
      }),
      -- tabs
      tablist,
      -- git info
      status.component.git_branch(),
      status.component.git_diff(),
      status.component.fill(),
      -- cmd info
      status.component.cmd_info(),
      status.component.fill(),
      -- now LSP and TS info
      status.component.diagnostics(),
      status.component.lsp(),
      status.component.treesitter(),
      -- file navigation
      status.component.nav(),
      -- mode color for the symmetry
      status.component.mode({ surround = { separator = "right" } }),
    }

    -- PORTED to v6: lua/plugins/heirline.lua shows filename + breadcrumbs when active,
    -- and a CWD-relative path when inactive or without breadcrumbs (left-truncated as needed).
    local file_info = {
      padding = { right = 1 }, -- this is not symmetric, but I like it
      -- PORTED to v6: lua/plugins/heirline.lua displays the file icon in the winbar.
      file_icon = {
        hl = status.hl.file_icon("winbar"),
        padding = { left = 0 },
      },
      -- PORTED to v6: lua/plugins/heirline.lua shows an unsaved-change dot in both winbar variants.
      file_modified = {},
      file_read_only = {},
      filetype = {
        separator = { left = " [", right = "]" },
      },
      unique_path = {},
      surround = false,
      hl = { bold = true, bg = "tabline_bg" },
      -- hl = status.hl.get_attributes("winbar", true),
    }
    local winbar_active = {
      condition = status.condition.is_active,
      status.component.separated_path(),
      status.component.file_info(file_info),
      status.component.breadcrumbs({ hl = status.hl.get_attributes("winbar", true) }),
    }

    file_info.file_icon.hl = status.hl.file_icon("winbarnc")
    file_info.hl = status.hl.get_attributes("winbarnc", true)
    local winbar_inactive = {
      status.component.separated_path(),
      status.component.file_info(file_info),
    }

    opts.winbar = {
      init = function(self)
        self.bufnr = vim.api.nvim_get_current_buf()
      end,
      fallthrough = false,
      winbar_active,
      winbar_inactive,
    }

    opts.statuscolumn = {
      status.component.foldcolumn(),
      status.component.signcolumn(),
      status.component.fill(),
      status.component.numbercolumn(),
    }

    -- return the final configuration table
    return opts
  end,
}
