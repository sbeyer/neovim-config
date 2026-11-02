local M = {}
local layouts = {}

local function git(root, args, callback)
  return vim.system(
    vim.list_extend({ "git", "--no-pager", "--no-optional-locks", "-C", root, "-c", "color.ui=false" }, args),
    { text = true, timeout = 10000 },
    callback
  )
end

local function path(name) return vim.uv.fs_realpath(name) or vim.fs.normalize(name) end

local function scratch(message, name, filetype)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, ("git-commit://%d/%s"):format(message, name))
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = filetype
  vim.bo[buf].modifiable = false
  vim.bo[buf].readonly = true
  return buf
end

local function display(win)
  for option, value in pairs {
    number = false,
    relativenumber = false,
    signcolumn = "no",
    statuscolumn = "",
    foldcolumn = "0",
    foldmethod = "manual",
    wrap = false,
    spell = false,
    list = false,
  } do
    vim.wo[win][option] = value
  end
end

local function populate(state, buf, title, args, empty)
  local function render(text)
    if not state.active or not vim.api.nvim_buf_is_valid(buf) then return end
    local lines = { title, "" }
    vim.list_extend(lines, vim.split(text:gsub("\n$", ""), "\n", { plain = true }))
    vim.bo[buf].readonly, vim.bo[buf].modifiable = false, true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modified = false
    vim.bo[buf].modifiable, vim.bo[buf].readonly = false, true
  end
  render "Loading..."
  state.jobs[#state.jobs + 1] = git(
    state.root,
    args,
    vim.schedule_wrap(
      function(result)
        render(
          result.code == 0 and (result.stdout ~= "" and result.stdout or empty) or ("Git failed:\n" .. result.stderr)
        )
      end
    )
  )
end

function M.open(buf)
  buf = buf or vim.api.nvim_get_current_buf()
  if layouts[buf] or buf ~= vim.api.nvim_get_current_buf() then return end
  local name = vim.api.nvim_buf_get_name(buf)
  local filename = vim.fs.basename(name)
  if filename ~= "COMMIT_EDITMSG" and filename ~= "MERGE_MSG" then return end
  if vim.fn.executable "git" ~= 1 or vim.api.nvim_win_get_height(0) < 10 then return end

  local root = git(vim.fn.getcwd(), { "rev-parse", "--show-toplevel" }):wait()
  if root.code ~= 0 then return end
  root = root.stdout:gsub("\n$", "")
  local target = git(root, { "rev-parse", "--path-format=absolute", "--git-path", filename }):wait()
  if target.code ~= 0 or path(target.stdout:gsub("\n$", "")) ~= path(name) then return end

  local edit = vim.api.nvim_get_current_win()
  local state = { active = true, root = root, buffers = {}, windows = {}, jobs = {} }
  layouts[buf] = state
  local group = vim.api.nvim_create_augroup("GitCommitLayout" .. buf, { clear = true })
  local function cleanup()
    if not state.active then return end
    state.active, layouts[buf] = false, nil
    vim.api.nvim_del_augroup_by_id(group)
    for _, job in ipairs(state.jobs) do
      job:kill(15)
    end
    for _, win in ipairs(state.windows) do
      if vim.api.nvim_win_is_valid(win) then pcall(vim.api.nvim_win_close, win, true) end
    end
    for _, helper in ipairs(state.buffers) do
      if vim.api.nvim_buf_is_valid(helper) then vim.api.nvim_buf_delete(helper, { force = true }) end
    end
  end

  local wide = vim.api.nvim_win_get_width(edit) >= 160
  local diff = scratch(buf, "staged.diff", "diff")
  state.buffers[#state.buffers + 1] = diff
  local diff_win = vim.api.nvim_open_win(diff, false, {
    split = wide and "right" or "below",
    win = edit,
    width = wide and (vim.api.nvim_win_get_width(edit) - 81) or nil,
    height = not wide and math.floor(vim.api.nvim_win_get_height(edit) / 2) or nil,
  })
  state.windows[#state.windows + 1] = diff_win
  display(diff_win)
  populate(
    state,
    diff,
    "Staged changes (index vs HEAD)",
    { "diff", "--cached", "--no-color", "--no-ext-diff", "--no-textconv" },
    "(No staged changes.)"
  )

  if wide then
    local status = scratch(buf, "status", "git")
    state.buffers[#state.buffers + 1] = status
    local status_win = vim.api.nvim_open_win(status, false, {
      split = "below",
      win = edit,
      height = math.min(10, math.floor(vim.api.nvim_win_get_height(edit) / 3)),
    })
    state.windows[#state.windows + 1] = status_win
    display(status_win)
    populate(
      state,
      status,
      "Git status (staged and unstaged)",
      { "status", "--short", "--branch" },
      "(Clean working tree.)"
    )
  end

  -- Remove helper windows before :wq decides whether this is the last window.
  vim.api.nvim_create_autocmd({ "QuitPre", "BufWinLeave", "BufWipeout" }, {
    group = group,
    buffer = buf,
    callback = cleanup,
  })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    pattern = tostring(edit),
    callback = cleanup,
  })
end

return M
