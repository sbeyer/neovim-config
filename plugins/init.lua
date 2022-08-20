return {
  -- Path navigator (minimalistic netrw alternative)
  'justinmk/vim-dirvish',

  -- ...with git support
  'kristijanhusak/vim-dirvish-git',

  -- support for file:line:col format
  'wsdjeg/vim-fetch',

  -- guess indentation settings
  'tpope/vim-sleuth',

  -- nicer git commit
  'rhysd/committia.vim',

  -- Rust goodies
  {
    'simrat39/rust-tools.nvim',

    requires = {
      "nvim-lspconfig",
      "nvim-lsp-installer",
      -- "nvim-dap",
    }
  },

  -- a few themes to test:
  'NLKNguyen/papercolor-theme',
  {
    'marko-cerovac/material.nvim',

    setup = function()
      vim.g.material_style = 'darker'
    end,

    config = function()
      require('material').setup{
        high_visibility = {
          darker = true
        }
      }
    end
  },

  {
    -- make w/b/e consider camelCase and snake_case
    'chaoren/vim-wordmotion',

    setup = function()
      vim.g.wordmotion_prefix = ','
    end
  },
}
