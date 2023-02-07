return {
  requires = "nvim-treesitter/nvim-treesitter",
  module = "neogen",
  cmd = "Neogen",
  config = function()
    require("neogen").setup {
      snippet_engine = "luasnip",
      languages = {
        lua = require('neogen.configurations.lua'),
        ['c.doxygen'] = require('neogen.configurations.c'),
        ['cpp.doxygen'] = require('neogen.configurations.cpp'),
        rust = require('neogen.configurations.rust'),
      },
    }
  end,
}
