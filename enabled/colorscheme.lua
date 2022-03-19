return {
  plug = {
    'bluz71/vim-nightfly-guicolors'
  },

  post = function()
    vim.o.termguicolors = true
    vim.cmd('colorscheme nightfly')
  end
}
