---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "gitcommit", "gitattributes", "git_rebase" } },
  },
}
