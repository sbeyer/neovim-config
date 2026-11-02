---@type LazySpec
return {
  "lewis6991/gitsigns.nvim",
  opts = function(_, opts)
    local on_attach = opts.on_attach
    opts.on_attach = function(bufnr)
      if on_attach and on_attach(bufnr) == false then return false end
      vim.keymap.set("n", "<Leader>gl", function() require("gitsigns").blame_line { full = true } end, {
        buffer = bufnr,
        desc = "View full Git blame",
      })
      pcall(vim.keymap.del, "n", "<Leader>gL", { buffer = bufnr })
    end
  end,
}
