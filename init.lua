local config = {
  colorscheme = "material",

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
