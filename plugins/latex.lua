return {
  require('user.utils').ensure_treesitter_parsers({ "latex", "bibtex" }),
  require('user.utils').ensure_lsps({ "texlab" }),
  require('user.utils').add_cmp_source(
    "kdheepak/cmp-latex-symbols",
    {
      name = "latex_symbols",
      option = { strategy = 2 }, -- show and insert the command
      priority = 700
      -- TODO: restrict to tex filetype
    }
  ),

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
