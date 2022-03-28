return {
  -- Path navigator (minimalistic netrw alternative)
  'justinmk/vim-dirvish',

  -- ...with git support
  'kristijanhusak/vim-dirvish-git',

  -- support for file:line:col format
  'wsdjeg/vim-fetch',

  -- guess indentation settings
  'tpope/vim-sleuth',

  -- nicer git commit
  'rhysd/committia.vim',

  {
    -- make w/b/e consider camelCase and snake_case
    'chaoren/vim-wordmotion',

    setup = function()
      vim.g.wordmotion_prefix = ','
    end
  },
}
