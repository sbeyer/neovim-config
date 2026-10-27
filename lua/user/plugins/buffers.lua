return {
  -- disable bufdelete (loaded by AstroNvim), it's not the behavior I want
  { "famiu/bufdelete.nvim", enabled = false },

  -- closing window leads to closing buffer if it is not active anymore
  {
    "mhinz/vim-sayonara",
    cmd = {
      "Sayonara",
    },
    keys = {
      {
        "<leader>q",
        "<cmd>Sayonara<cr>",
        desc = "Close window / quit",
        mode = { "n" },
      },
    },
  },
}
