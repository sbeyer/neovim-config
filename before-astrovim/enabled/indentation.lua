return {
  plug = {
    'lukas-reineke/indent-blankline.nvim',
  },

  post = function()
    require('indent_blankline').setup {
      -- this needs treesitter: show_current_context = true,
    }
  end
}
