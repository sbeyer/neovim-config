return {
  'lukas-reineke/indent-blankline.nvim',

  config = function()
    require('indent_blankline').setup {
      -- this needs treesitter: show_current_context = true,
    }
  end
}
