return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-calc" },
    opts_extend = { "sources" },
    opts = { sources = { { name = "calc" } } },
  },
}
