return {
  plug = {
    -- make w/b/e consider camelCase and snake_case
    'chaoren/vim-wordmotion',
  },

  pre = function()
    vim.g.wordmotion_prefix = '<Leader>'
    end
}
