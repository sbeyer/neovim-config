---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "json", "yaml" } },
  },
}
