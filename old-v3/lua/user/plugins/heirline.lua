return {
  "rebelot/heirline.nvim",
  opts = function(_, opts)
    local status = require("astronvim.utils.status")

    -- remove tabline
    opts.tabline = {}

    -- tab information in statusline
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

    local file_info = {
      padding = { right = 1 }, -- this is not symmetric, but I like it
      file_icon = {
        hl = status.hl.file_icon("winbar"),
        padding = { left = 0 },
      },
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
