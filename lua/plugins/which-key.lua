---@type LazySpec
return {
  "folke/which-key.nvim",
  opts = {
    win = {
      -- With the cursor on the bottom window row, no_overlap leaves the popup empty.
      no_overlap = false,
    },
  },
}
