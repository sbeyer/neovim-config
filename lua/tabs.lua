local M = {}
local history = {}

local function remember()
  local current = vim.api.nvim_get_current_tabpage()
  local recent = { current }
  for _, tab in ipairs(history) do
    if tab ~= current and vim.api.nvim_tabpage_is_valid(tab) then recent[#recent + 1] = tab end
  end
  history = recent
end

function M.setup()
  remember()
  vim.api.nvim_create_autocmd("TabEnter", {
    group = vim.api.nvim_create_augroup("UserTabHistory", { clear = true }),
    desc = "Remember recently visited tabs",
    callback = remember,
  })
end

function M.previous()
  remember()
  if history[2] then
    vim.api.nvim_set_current_tabpage(history[2])
  else
    vim.notify("No previously visited tab", vim.log.levels.INFO, { title = "Tabs" })
  end
end

function M.pick()
  local current = vim.api.nvim_get_current_tabpage()
  local items = {}
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local names, seen = {}, {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_win_get_config(win).relative == "" and not seen[buf] then
        seen[buf] = true
        local name = vim.api.nvim_buf_get_name(buf)
        names[#names + 1] = name ~= "" and vim.fn.fnamemodify(name, ":~:.") or "[No Name]"
      end
    end
    items[#items + 1] = {
      tab = tab,
      text = table.concat(names, ", ") .. (tab == current and " [current]" or ""),
    }
  end
  vim.ui.select(items, {
    prompt = "Tabs",
    format_item = function(item) return item.text end,
  }, function(item)
    if item and vim.api.nvim_tabpage_is_valid(item.tab) then vim.api.nvim_set_current_tabpage(item.tab) end
  end)
end

return M
