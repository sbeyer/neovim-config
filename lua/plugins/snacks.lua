---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    -- Snacks picker input highlighting uses the regex parser.
    treesitter = { ensure_installed = { "regex" } },
  },
}
