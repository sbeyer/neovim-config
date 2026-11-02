---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local mappings = opts.mappings.n
    for _, keys in ipairs {
      { "[T", "[x" },
      { "]T", "]x" },
      { "<Leader>fT", "<Leader>fx" },
      { "<Leader>ft", "<Leader>fT" },
    } do
      local old, new = keys[1], keys[2]
      mappings[new] = mappings[old]
      mappings[old] = false
    end
  end,
}
