return {
  -- undo tree via telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      -- require("telescope").setup({
      --   extensions = {
      --     undo = {
      --       -- keep defaults
      --     },
      --   },
      -- })
      require("telescope").load_extension("undo")
    end,
    keys = {
      {
        "<leader>fu",
        "<cmd>Telescope undo<cr>",
        desc = "Undo tree",
      },
    },
  },
}
