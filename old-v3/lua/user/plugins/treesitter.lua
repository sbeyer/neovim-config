return {
  "nvim-treesitter/nvim-treesitter",
  opts = function(_, opts)
    opts.auto_install = true

    -- some general parsers not contained in our other configs
    opts.ensure_installed = {
      "bash",
      "go",
      "lua",
      "markdown",
      "python",
      "qmljs",
      "ruby",
      "vim",
      "vimdoc",
    }
  end,
}
