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

M.ensure_lsps = function(lsps)
  return {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end

      vim.list_extend(opts.ensure_installed, lsps)
    end,
  }
end

M.add_cmp_source = function(plugin, source_config)
  return {
    "hrsh7th/nvim-cmp",
    dependencies = { plugin },
    opts = function(_, opts)
      if not opts.sources then
        opts.sources = {}
      end

      table.insert(opts.sources, source_config)
    end,
  }
end

return M
