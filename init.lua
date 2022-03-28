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

    -- enable mouse only for Normal and Visual mode only
    vim.o.mouse = 'nv'

    ----- File-type specific configuration

    -- I never deal with plain tex, always LaTeX... respect that!
    vim.cmd('autocmd FileType plaintex set ft=tex')

    -- disable displaying math (etc) for TeX and LaTeX
    vim.cmd('autocmd FileType tex set conceallevel=0')

    ----- Mappings
    local opts = { noremap = true, silent = true }
    local map = vim.api.nvim_set_keymap
    map("n", "<leader>gR", "<cmd>!git rm -f %<cr>", opts)
    map("n", "<leader>gw", "<cmd>!git add %<cr>", opts)

    map('n', '<leader>fW', '<cmd>lua require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>") })<cr>', opts)
  end
}

return config
