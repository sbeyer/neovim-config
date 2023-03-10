return {
  -- File browser via telescope
  {
    "nvim-telescope/telescope-file-browser.nvim",
    config = function() require("telescope").load_extension "file_browser" end,
    keys = {
      {
        "<leader>fe",
        "<cmd>Telescope file_browser<cr>",
        desc = "File explorer",
      },
    },
  },
}
