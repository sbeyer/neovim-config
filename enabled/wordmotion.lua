return {
  -- make w/b/e consider camelCase and snake_case
  'chaoren/vim-wordmotion',

  setup = function()
    vim.g.wordmotion_prefix = '<Leader>'
  end
}
