return {
  'bluz71/vim-nightfly-guicolors',

  config = function()
    vim.o.termguicolors = true
    vim.cmd('colorscheme nightfly')
  end
}
