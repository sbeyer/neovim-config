---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "latex", "bibtex" } },
  },
}
