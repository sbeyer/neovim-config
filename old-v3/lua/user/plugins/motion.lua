return {
  -- make w/b/e consider camelCase and snake_case
  {
    "chaoren/vim-wordmotion",
    lazy = false,
    init = function()
      vim.g.wordmotion_prefix = "_"
    end,
  },

  -- XXX: vim-matchup is disabled because matchit is enabled since AstroNvim 3.10.3
  -- navigate on matching text using '%'
  -- {
  --   "AstroNvim/astrocommunity",
  --   version = "^6",
  --   { import = "astrocommunity.motion.vim-matchup" },
  --   {
  --     "vim-matchup",
  --     init = function()
  --       vim.g.matchup_matchparen_offscreen = { method = "popup" }
  --     end,
  --   },
  -- },
}
