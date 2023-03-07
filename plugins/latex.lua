return {
  require('user.utils').ensure_treesitter_parsers({ "latex", "bibtex" }),

  -- Ensure texlab LSP is installed
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end

      vim.list_extend(opts.ensure_installed, { "texlab" })
    end,
  },

  -- cmp source for latex symbols
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "kdheepak/cmp-latex-symbols" },
    opts = function(_, opts)
      if not opts.sources then
        opts.sources = {}
      end

      table.insert(opts.sources, {
        name = "latex_symbols",
        option = { strategy = 2 }, -- show and insert the command
        priority = 700
      })
    end,
  },

  -- BibTeX finder in telescope
  {
    "nvim-telescope/telescope-bibtex.nvim",
    config = function()
      require("telescope").load_extension "bibtex"
    end,
    keys = {
      {
        "<leader>fB",
        "<cmd>Telescope bibtex<cr>",
        desc = "Search bibliography",
      }
    }
  }
}
