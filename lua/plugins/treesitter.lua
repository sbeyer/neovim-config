-- Customize Treesitter
-- --------------------
-- Treesitter customizations are handled with AstroCore
-- as nvim-treesitter simply provides a download utility for parsers

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    treesitter = {
      highlight = true, -- enable/disable treesitter based highlighting
      indent = true, -- enable/disable treesitter based indentation
      auto_install = true, -- enable/disable automatic installation of detected languages
      -- General parsers not grouped with purpose-specific settings.
      ensure_installed = {
        "bash",
        "diff",
        "go",
        "lua",
        "markdown",
        "python",
        "qmljs",
        "ruby",
        "vim",
        "vimdoc",
        -- add more arguments for adding more treesitter parsers
      },
    },
  },
}
