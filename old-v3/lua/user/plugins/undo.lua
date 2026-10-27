return {
  -- undo tree via telescope
  {
    "debugloop/telescope-undo.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
    config = function()
      require("telescope").setup({
        extensions = {
          undo = {
            entry_format = "#$ID - $TIME: $STAT",
          },
        },
      })
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
