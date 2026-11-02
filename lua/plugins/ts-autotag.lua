---@type LazySpec
return {
  "windwp/nvim-ts-autotag",
  -- Preserve the native XSD filetype while using XML parsing and tag rules.
  init = function() vim.treesitter.language.register("xml", "xsd") end,
  opts = { aliases = { xsd = "xml" } },
}
