return {
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
