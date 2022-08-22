return {
  -- disable AstroNvim's smooth scrolling
  ["declancm/cinnamon.nvim"] = { disable = true },

  -- disable plugins I do not use
  ["famiu/bufdelete.nvim"] = { disable = true },
  ["goolord/alpha-nvim"] = { disable = true },

  -- support for file:line:col format
  'wsdjeg/vim-fetch',

  -- guess indentation settings (disable unused AstoNvim choice)
  ['NMAC427/guess-indent.nvim'] = require 'user.plugins.guess-indent',
  ["Darazaki/indent-o-matic"] = { disable = true },

  -- nicer git commit
  'rhysd/committia.vim',

  -- Rust goodies
  ["simrat39/rust-tools.nvim"] = require "user.plugins.rust-tools",

  -- C/C++ goodies
  ["p00f/clangd_extensions.nvim"] = require "user.plugins.clangd_extensions",

  -- Colorscheme
  ['marko-cerovac/material.nvim'] = require "user.plugins.material",

  -- make w/b/e consider camelCase and snake_case
  ['chaoren/vim-wordmotion'] = require "user.plugins.wordmotion",
}
