return {
  -- LSP function signature awesomeness
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead", -- LspAttach would be nicer, but does not work :(
    config = function()
      require("lsp_signature").setup({
        toggle_key = "<M-x>",
        select_signature_key = "<M-n>",
      })
    end,
  },
}
