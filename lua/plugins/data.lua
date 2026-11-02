---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "dtd", "json", "xml", "yaml" } },
  },
}
