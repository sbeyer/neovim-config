return {
  config = function()
    require('lsp_signature').setup {
      toggle_key = '<M-x>',
      select_signature_key = '<M-n>',
    }
  end
}
