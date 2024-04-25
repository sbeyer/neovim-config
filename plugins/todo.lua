return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
      {
        "[x",
        function() require("todo-comments").jump_prev() end,
        desc = "Previous TODO comment",
      },
      {
        "]x",
        function() require("todo-comments").jump_next() end,
        desc = "Next TODO comment",
      },
      {
        "<leader>fx",
        "<cmd>TodoTelescope<cr>",
        desc = "Find TODO comment",
      },
    },
  },
}
