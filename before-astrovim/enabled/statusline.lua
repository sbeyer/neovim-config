return {
  plug = {
    'nvim-lualine/lualine.nvim',

    requires = {
      'kyazdani42/nvim-web-devicons',
      opt = true,
    },
  },

  post = function()
    local lualine = require('lualine')
    lualine.get_config()
    lualine.setup {
      options = {
        -- theme = 'dracula'
        theme = 'nightfly' -- assumes that nightfly is loaded in colorscheme.lua
      }
    }
  end
}