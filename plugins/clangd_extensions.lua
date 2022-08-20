return {
  after = "mason-lspconfig.nvim",
  config = function()
    require("clangd_extensions").setup {
      server = astronvim.lsp.server_settings "clangd",
    }
  end,
}
