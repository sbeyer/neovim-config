return {
  -- make w/b/e consider camelCase and snake_case
  {
    'chaoren/vim-wordmotion',
    lazy = false,
    init = function()
      vim.g.wordmotion_prefix = ','
    end
  },
}
