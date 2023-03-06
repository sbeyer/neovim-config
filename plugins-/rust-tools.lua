return {
  after = "mason-lspconfig.nvim",
  config = function()
    require("rust-tools").setup {
      -- get the server settings and built in capabilities/on_attach
      server = astronvim.lsp.server_settings "rust_analyzer",
    }
  end,
}
