---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    local mappings = opts.mappings.n
    for old, new in pairs { ["[T"] = "[x", ["]T"] = "]x", ["<Leader>fT"] = "<Leader>fx" } do
      mappings[new] = mappings[old]
      mappings[old] = false
    end
  end,
}
