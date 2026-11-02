return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts_extend = { "ensure_installed" },
    opts = { ensure_installed = { "rust_analyzer", "taplo" } },
  },

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
