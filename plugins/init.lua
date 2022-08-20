return {
  -- support for file:line:col format
  'wsdjeg/vim-fetch',

  -- guess indentation settings
  'tpope/vim-sleuth',

  -- nicer git commit
  'rhysd/committia.vim',

  -- Rust goodies
  {
    "simrat39/rust-tools.nvim",
    after = "mason-lspconfig.nvim",
    config = function()
      require("rust-tools").setup {
        -- get the server settings and built in capabilities/on_attach
        server = astronvim.lsp.server_settings "rust_analyzer",
      }
    end,
  },

  -- C/C++ goodies
  {
    "p00f/clangd_extensions.nvim",
    after = "mason-lspconfig.nvim",
    config = function()
      require("clangd_extensions").setup {
        server = astronvim.lsp.server_settings "clangd",
      }
    end,
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
