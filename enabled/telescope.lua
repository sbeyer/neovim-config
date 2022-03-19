return {
  plug = {
    -- Telescope itself
    'nvim-telescope/telescope.nvim',

    requires = {
      -- Neovim's LUA "standard library" :)
      'nvim-lua/plenary.nvim',
    },
  },

  post = function()
    vim.api.nvim_set_keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', {noremap = true})
    vim.api.nvim_set_keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', {noremap = true})

    require('telescope').setup {
      defaults = {
	mappings = {
	  i = {
	    ["<C-Down>"] = require('telescope.actions').cycle_history_next,
	    ["<C-Up>"]   = require('telescope.actions').cycle_history_prev,
	    ["<C-h>"]    = require('telescope.actions').which_key,
	  },
	},
      },
    }
  end
}
