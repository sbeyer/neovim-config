return {
  -- disable plugins I do not use
  ["famiu/bufdelete.nvim"] = { disable = true },
  ["goolord/alpha-nvim"] = { disable = true },
  ["akinsho/bufferline.nvim"] = { disable = true },

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

  -- navigate on matching text using %
  ['andymass/vim-matchup'] = require "user.plugins.matchup",

  -- fast motion
  'rlane/pounce.nvim',

  -- annotation generation
  ['danymat/neogen'] = require "user.plugins.neogen",

  -- completions that do calculations for me
  ["hrsh7th/cmp-calc"] = require "user.plugins.cmp-calc",

  -- LaTeX symbol completions
  ["kdheepak/cmp-latex-symbols"] = require "user.plugins.cmp-latex-symbols",

  -- BibTeX finder in telescope
  ["nvim-telescope/telescope-bibtex.nvim"] = require "user.plugins.telescope-bibtex",

  -- File browser via telescope
  ["nvim-telescope/telescope-file-browser.nvim"] = require "user.plugins.telescope-file-browser",

  -- git goodies for diffs, conflicts and history
  ["sindrets/diffview.nvim"] = require "user.plugins.diffview",
}
