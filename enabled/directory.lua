return {
  plug = {
    -- Path navigator
    'justinmk/vim-dirvish',

    -- ...with git support
    'kristijanhusak/vim-dirvish-git',
  },

  pre = function()
    -- disable netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
  end
}
