local M = {}

local function notify(message, level) vim.notify(message, level or vim.log.levels.ERROR, { title = "Remove Git file" }) end

local function git(directory, args)
  return vim.system(vim.list_extend({ "git", "--literal-pathspecs", "-C", directory }, args), { text = true }):wait()
end

local function file_path(name)
  return vim.fs.joinpath(vim.uv.fs_realpath(vim.fs.dirname(name)) or vim.fs.dirname(name), vim.fs.basename(name))
end

local function file_buffers(path)
  local buffers = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name ~= "" and file_path(name) == path then table.insert(buffers, buf) end
  end
  return buffers
end

function M.current()
  local buf = vim.api.nvim_get_current_buf()
  local name = vim.api.nvim_buf_get_name(buf)
  if name == "" or vim.bo[buf].buftype ~= "" then return notify "The current buffer is not a file." end
  if vim.fn.executable "git" ~= 1 then return notify "Git is not installed." end
  local path = file_path(name)
  local stat = vim.uv.fs_lstat(path)
  if stat and stat.type ~= "file" and stat.type ~= "link" then return notify "Only individual files can be removed." end

  local root = git(vim.fs.dirname(path), { "rev-parse", "--show-toplevel" })
  if root.code ~= 0 then return notify "The current file is not in a Git working tree." end
  root = root.stdout:gsub("\n$", "")
  local relative = vim.fs.relpath(root, path)
  if not relative then return notify "The current file is outside the Git working tree." end
  local tracked = git(root, { "ls-files", "--error-unmatch", "--", relative })
  if tracked.code ~= 0 then return notify "The current file is not tracked by Git." end
  local status = git(root, { "status", "--porcelain=v1", "--untracked-files=no", "--", relative })
  if status.code ~= 0 then return notify(status.stderr) end

  local modified = false
  for _, buffer in ipairs(file_buffers(path)) do
    modified = modified or vim.bo[buffer].modified
  end
  local staged = status.stdout ~= "" and status.stdout:sub(1, 1) ~= " "
  local unstaged = status.stdout ~= "" and status.stdout:sub(2, 2) ~= " "
  local choices = {
    { label = "Cancel", action = "cancel" },
    { label = "Delete from disk and Git (discard unsaved edits)", action = "delete" },
    { label = "Untrack in Git, keep file and buffer", action = "untrack" },
  }
  vim.ui.select(choices, {
    prompt = ("%s [unsaved buffer: %s; staged: %s; unstaged: %s]"):format(
      relative,
      modified and "yes" or "no",
      staged and "yes" or "no",
      unstaged and "yes" or "no"
    ),
    format_item = function(item) return item.label end,
  }, function(choice)
    if not choice or choice.action == "cancel" then return end
    local args = { "rm", "-f" }
    if choice.action == "untrack" then table.insert(args, "--cached") end
    vim.list_extend(args, { "--", relative })
    local result = git(root, args)
    if result.code ~= 0 then return notify("Git removal failed: " .. result.stderr) end

    local snacks = require "snacks"
    if choice.action == "delete" then
      for _, buffer in ipairs(file_buffers(path)) do
        snacks.bufdelete { buf = buffer, force = true }
      end
    end
    notify(
      (choice.action == "delete" and "Deleted and staged removal: " or "Untracked, kept on disk: ") .. relative,
      vim.log.levels.INFO
    )
    local search, regex = vim.fs.basename(path), false
    -- Snacks interprets " -- " as extra rg arguments, even in literal mode.
    if search:find "%s%-%-" then
      search, regex = vim.fn.escape(search, [[\.^$*+?()[]{}|-]]), true
    end
    snacks.picker.grep {
      cwd = root,
      search = search,
      regex = regex,
      hidden = true,
      title = "Filename references (removal already staged)",
    }
  end)
end

return M
