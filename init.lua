local config = {
  colorscheme = "material",

  options = {
    opt = {
      -- status line everywhere
      laststatus = 2,

      -- completion behavior in command mode
      wildmode = 'longest:full,full',

      -- disable weird completion behavior regarding suffixes
      suffixes = '',

      -- enable mouse only for Normal and Visual mode only
      mouse = 'nv',

      -- make whitespace visible
      list = true,
      listchars = 'tab:^`,trail:~,extends:\\,precedes:»',

      -- make implicit linebreaks visible
      wrap = true,
      showbreak = '  «',
      breakindent = true,
      breakindentopt = 'shift:2,sbr',
    }
  },

  polish = function()
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
  end
}

return config
