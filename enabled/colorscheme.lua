return {
  plug = {
    'chriskempson/base16-vim'
  },

  post = function()
    vim.o.termguicolors = true
    -- Some example colorschemes from base16-vim that I liked, i.e., dark themes
    -- that have a good contrast and are colorful without being ugly
    -- vim.cmd('colorscheme base16-brewer')
    -- vim.cmd('colorscheme base16-chalk')
    -- vim.cmd('colorscheme base16-classic-dark')
    -- vim.cmd('colorscheme base16-helios')
    vim.cmd('colorscheme base16-seti')
  end
}
