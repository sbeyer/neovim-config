return {
  require("user.utils").ensure_treesitter_parsers({ "css", "elm", "html", "javascript", "php" }),

  -- automatically add end tags and replace them accordingly
  {
    "windwp/nvim-ts-autotag",
    lazy = "VeryLazy",
    config = function()
      require("nvim-treesitter.configs").setup({
        autotag = {
          enable = true,
        },
      })
    end,
  },
}
