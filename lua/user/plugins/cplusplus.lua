return {
  require("user.utils").ensure_treesitter_parsers({ "c", "cpp", "cmake", "comment", "makeweb" }),
  require("user.utils").ensure_lsps({ "clangd" }),

  -- C/C++ goodies
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    opts = function()
      return {
        extensions = {
          inlay_hints = {
            highlight = "DiagnosticVirtualTextOk",
          },
          ast = {
            highlight = "DiagnosticVirtualTextOk",
          },
        },
        server = require("astronvim.utils.lsp").config("clangd"),
      }
    end,
  },
}
