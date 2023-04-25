return {
  require("user.utils").ensure_treesitter_parsers({ "rust", "toml" }),
  require("user.utils").ensure_lsps({ "rust_analyzer", "taplo" }),

  {
    "AstroNvim/astrocommunity",
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
