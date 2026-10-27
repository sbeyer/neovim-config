return {
  "marko-cerovac/material.nvim",
  init = function()
    vim.g.material_style = "darker" -- "deep ocean" is also quite nice!
  end,
  config = function()
    local colors = require("material.colors")
    require("material").setup({
      contrast = {
        non_current_windows = true,
        cursor_line = true,
        floating_windows = true,
      },
      styles = {
        comments = { italic = true },
        functions = { bold = true },
      },
      high_visibility = {
        darker = true,
      },
      plugins = {
        "dap",
        "gitsigns",
        -- "indent-blankline", -- we use the plugin but the theme makes it worse
        "nvim-cmp",
        "nvim-web-devicons",
        "telescope",
        "which-key",
      },
      custom_highlights = {
        DiagnosticVirtualTextError = {
          fg = colors.lsp.error,
          bg = colors.main.black,
          italic = true,
        },
        DiagnosticVirtualTextHint = {
          fg = colors.lsp.hint,
          bg = colors.main.black,
          italic = true,
        },
        DiagnosticVirtualTextInfo = {
          fg = colors.lsp.info,
          bg = colors.main.black,
          italic = true,
        },
        DiagnosticVirtualTextOk = {
          fg = colors.lsp.info,
          bg = colors.main.black,
          italic = true,
        },
        DiagnosticVirtualTextWarn = {
          fg = colors.lsp.warning,
          bg = colors.main.black,
          italic = true,
        },
      },
    })
  end,
}
