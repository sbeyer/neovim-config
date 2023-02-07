return {
  after = "nvim-cmp",
  config = function()
    astronvim.add_user_cmp_source "latex_symbols"
  end,
}
