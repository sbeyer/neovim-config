local config = {
  polish = function()
    ----- General configuration

    -- make whitespace visible
    vim.wo.list = true
    vim.o.listchars = 'tab:^`,trail:~,extends:\\,precedes:»'

    -- make implicit linebreaks visible
    vim.wo.wrap = true
    vim.o.showbreak = '  «'
    vim.wo.breakindent = true
    vim.wo.breakindentopt = 'shift:2,sbr'

    -- completion behavior in command mode
    vim.o.wildmode = 'longest:full,full'

    -- disable weird completion behavior
    vim.o.suffixes = ''

    -- define , as our leader key
    -- vim.g.mapleader = ','

    ----- File-type specific configuration

    -- I never deal with plain tex, always LaTeX... respect that!
    vim.cmd('autocmd FileType plaintex set ft=tex')

    -- disable displaying math (etc) for TeX and LaTeX
    vim.cmd('autocmd FileType tex set conceallevel=0')
  end
}

return config
