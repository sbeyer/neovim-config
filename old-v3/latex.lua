return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts_extend = { "ensure_installed" },
    opts = { ensure_installed = { "texlab" } },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "kdheepak/cmp-latex-symbols" },
    opts_extend = { "sources" },
    opts = {
      sources = {
        {
          name = "latex_symbols",
          option = { strategy = 2 }, -- show and insert the command
          priority = 700,
          -- TODO: restrict to tex filetype
        },
      },
    },
  },

  -- BibTeX finder in telescope
  {
    "nvim-telescope/telescope-bibtex.nvim",
    config = function() require("telescope").load_extension "bibtex" end,
    keys = {
      {
        "<leader>fB",
        "<cmd>Telescope bibtex<cr>",
        desc = "Search bibliography",
      },
    },
  },
}
