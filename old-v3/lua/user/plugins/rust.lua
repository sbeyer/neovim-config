return {
  require("user.utils").ensure_lsps({ "rust_analyzer", "taplo" }),

  {
    "AstroNvim/astrocommunity",
    version = "^6",
    { import = "astrocommunity.pack.rust" },
  },
  {
    "simrat39/rust-tools.nvim",
    opts = {
      tools = {
        inlay_hints = {
          highlight = "DiagnosticVirtualTextOk",
        },
      },
    },
  },
}
