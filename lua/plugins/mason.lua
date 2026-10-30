---@type LazySpec
return {
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      for index, server in ipairs(opts.ensure_installed or {}) do
        if server == "clangd" or server:match "^clangd@" then
          opts.ensure_installed[index] = "clangd@" .. vim.g.clangd_version
        end
      end
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      for index, tool in ipairs(opts.ensure_installed or {}) do
        local name = type(tool) == "table" and tool[1] or tool
        if name == "clangd" or name:match "^clangd@" then
          opts.ensure_installed[index] =
            vim.tbl_extend("force", type(tool) == "table" and tool or {}, { "clangd", version = vim.g.clangd_version })
        end
      end
    end,
  },
}
