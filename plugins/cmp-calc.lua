return {
  -- cmp source for calculations
  {
    "hrsh7th/nvim-cmp",
    dependencies = { "hrsh7th/cmp-calc" },
    opts = function(_, opts)
      if not opts.sources then
        opts.sources = {}
      end

      table.insert(opts.sources, {
        name = "calc",
      })
    end,
  },
}
