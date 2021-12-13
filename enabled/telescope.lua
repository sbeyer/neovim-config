return {
  -- Telescope itself
  'nvim-telescope/telescope.nvim',

  requires = {
    -- Neovim's LUA "standard library" :)
    'nvim-lua/plenary.nvim',
  },

  config = function()
    vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', {noremap = true})
  end
}
