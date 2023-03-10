return {
  -- make w/b/e consider camelCase and snake_case
  {
    'chaoren/vim-wordmotion',
    lazy = false,
    init = function()
      vim.g.wordmotion_prefix = ','
    end
  },

  -- fast motion
  {
    'rlane/pounce.nvim',
    keys = {
      {
        "s",
        "<cmd>Pounce<CR>",
        desc = "Jump to ...",
        mode = { "n", "v" },
      },
      {
        "S",
        "<cmd>PounceRepeat<CR>",
        desc = "Repeat 'Jump to'",
        mode = { "n", "v" },
      },
    }
  }
}
