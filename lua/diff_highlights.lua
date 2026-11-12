local M = {}
local saved = {}
local deletion = "DiffTextAdd:DiffTextDelete"

local function replace_mapping(win, replacement)
  local mappings, previous = {}, ""
  for mapping in vim.wo[win].winhighlight:gmatch "[^,]+" do
    if mapping:match "^DiffTextAdd:" then
      previous = mapping
    else
      mappings[#mappings + 1] = mapping
    end
  end
  if replacement ~= "" then mappings[#mappings + 1] = replacement end
  vim.wo[win].winhighlight = table.concat(mappings, ",")
  return previous
end

function M.update()
  for win, previous in pairs(saved) do
    if vim.api.nvim_win_is_valid(win) and vim.wo[win].winhighlight:find(deletion, 1, true) then
      replace_mapping(win, previous)
    end
  end
  saved = {}

  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local windows = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      if vim.wo[win].diff then windows[#windows + 1] = win end
    end
    -- Multi-way diffs have no unambiguous old/new pane.
    if #windows == 2 then
      table.sort(windows, function(a, b)
        local first, second = vim.api.nvim_win_get_position(a), vim.api.nvim_win_get_position(b)
        return first[2] < second[2] or (first[2] == second[2] and first[1] < second[1])
      end)
      saved[windows[1]] = replace_mapping(windows[1], deletion)
    end
  end
end

return M
