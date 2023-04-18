return {
  {
    "AstroNvim/astrocommunity",
    { import = "astrocommunity.utility.noice-nvim" },
    {
      "noice.nvim",
      opts = {
        lsp = {
          signature = {
            enabled = false,
          },
        },
      },
    },
  },
}
