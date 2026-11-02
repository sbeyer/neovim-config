local config = vim.deepcopy(require "clangd.compile-commands")
local find_root = config.root_dir

config.root_dir = function(bufnr, on_dir)
  require("clangd.version").ensure(function(available)
    if available and vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
      find_root(bufnr, on_dir)
    end
  end)
end

return config
