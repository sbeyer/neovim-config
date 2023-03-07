local M = {}

M.ensure_treesitter_parsers = function(parsers)
  return {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      elseif opts.ensure_installed == "all" then
        return
      end

      table.insert(opts.ensure_installed, parsers)
    end,
  }
end

return M
