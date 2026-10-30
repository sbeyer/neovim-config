---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "gitcommit", "gitattributes", "git_rebase" } },
    mappings = {
      n = {
        ["<Leader>gD"] = {
          function() require("git.remove").current() end,
          desc = "Remove current file from Git",
        },
      },
    },
  },
}
