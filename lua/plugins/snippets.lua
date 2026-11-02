---@type LazySpec
return {
  "L3MON4D3/LuaSnip",
  opts = function(_, opts)
    local filetypes = opts.ft_func or function() return vim.split(vim.bo.filetype, ".", { plain = true }) end
    opts.ft_func = function() return require("snippets.project").filetypes(filetypes()) end
  end,
}
