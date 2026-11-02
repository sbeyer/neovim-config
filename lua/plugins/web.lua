---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "css", "elm", "html", "javascript", "php" } },
  },
}
