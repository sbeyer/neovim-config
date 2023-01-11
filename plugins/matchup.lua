return {
  after = "nvim-treesitter",
  setup = function()
    vim.g.matchup_matchparen_offscreen = { method = "popup" }
  end
}
