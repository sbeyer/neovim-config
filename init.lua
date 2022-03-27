local config = {
  polish = function()
    ----- General configuration

    -- make whitespace visible
    vim.wo.list = true
    vim.o.listchars = 'tab:^`,trail:~,extends:\\,precedes:»'

    -- make implicit linebreaks visible
    vim.o.showbreak = '  «'
    vim.wo.breakindent = true
    vim.wo.breakindentopt = 'shift:2,sbr'

    -- completion behavior in command mode
    vim.o.wildmode = 'longest:full,full'

    -- find: ignore case when all letters are lower-case
    vim.o.smartcase = true
    vim.o.ignorecase = true

    -- disable weird completion behavior
    vim.o.suffixes = ''

    -- always keep some rows/columns when scrolling
    vim.o.scrolloff = 5
    vim.o.sidescrolloff = 8

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
