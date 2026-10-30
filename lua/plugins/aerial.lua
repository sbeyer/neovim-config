---@type LazySpec
return {
  "stevearc/aerial.nvim",
  opts = {
    post_add_all_symbols = function(bufnr, items, ctx)
      if ctx.backend_name ~= "treesitter" or ctx.lang ~= "diff" then return items end

      -- Without index metadata, the parser can leave hunks outside their file blocks.
      local roots, file = {}, nil
      for _, item in ipairs(items) do
        if item.kind == "File" then
          file = item
          table.insert(roots, item)
        elseif file and item.kind == "Function" then
          file.children = file.children or {}
          item.parent, item.level = file, file.level + 1
          table.insert(file.children, item)
        else
          table.insert(roots, item)
        end
      end

      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local function set_end(item, lnum)
        item.end_lnum, item.end_col = lnum, #lines[lnum]
      end
      for index, item in ipairs(roots) do
        set_end(item, roots[index + 1] and roots[index + 1].lnum - 1 or #lines)
        local children = item.children or {}
        for child_index, child in ipairs(children) do
          set_end(child, children[child_index + 1] and children[child_index + 1].lnum - 1 or item.end_lnum)
        end
      end
      return roots
    end,
  },
}
