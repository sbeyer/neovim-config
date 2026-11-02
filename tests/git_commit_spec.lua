local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local commit = require "git.commit"
local config = vim.fn.getcwd()
local temporary, original_cwd, original_columns, original_lines, message

local function git(...)
  local result = vim
    .system(
      vim.list_extend(
        { "git", "-C", temporary, "-c", "user.name=Test", "-c", "user.email=test@example.invalid" },
        { ... }
      ),
      { text = true }
    )
    :wait()
  assert.equals(0, result.code, result.stderr)
  return result.stdout
end

local function stage(name, text)
  vim.fn.writefile({ text }, vim.fs.joinpath(temporary, name))
  git("add", "--", name)
end

local function open(name)
  local target = git("rev-parse", "--path-format=absolute", "--git-path", name or "COMMIT_EDITMSG"):gsub("\n$", "")
  vim.fn.writefile({ "", "# Commit message fixture" }, target)
  vim.cmd.edit(vim.fn.fnameescape(target))
  message = vim.api.nvim_get_current_buf()
  commit.open(message)
end

local function helpers()
  local result = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(buf)
    if name:match "^git%-commit://" then result[vim.fs.basename(name)] = buf end
  end
  return result
end

local function contents(buf) return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") end

local function loaded()
  assert.is_not_nil(helpers()["staged.diff"])
  assert(vim.wait(3000, function()
    for _, buf in pairs(helpers()) do
      if contents(buf):find("Loading...", 1, true) then return false end
    end
    return true
  end))
end

local function editor(action)
  local script = vim.fs.joinpath(temporary, "editor.lua")
  vim.fn.writefile(
    vim.split(
      ([[
vim.opt.rtp:prepend(%q)
vim.o.columns, vim.o.lines = 180, 50
local autocmd = dofile(%q).opts.autocmds.git_commit_layout[1]
vim.api.nvim_create_autocmd(autocmd.event, { once = true, callback = autocmd.callback })
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.defer_fn(function()
      local ok, err = pcall(function()
        assert(#vim.api.nvim_tabpage_list_wins(0) == 3, "Commit layout did not open")
        assert(vim.fs.basename(vim.api.nvim_buf_get_name(0)) == "COMMIT_EDITMSG")
        vim.api.nvim_buf_set_lines(0, 0, -1, false, { "Commit from editor fixture" })
        %s
      end)
      if not ok then
        io.stderr:write(tostring(err))
        vim.cmd "cquit 9"
      end
    end, 100)
  end,
})
]]):format(config, vim.fs.joinpath(config, "lua/plugins/git.lua"), action),
      "\n",
      { plain = true }
    ),
    script
  )
  return table.concat({
    vim.fn.shellescape(vim.v.progpath),
    "--headless -u NONE -i NONE -n -c",
    vim.fn.shellescape("luafile " .. vim.fn.fnameescape(script)),
  }, " ")
end

describe("Git commit editor layout", function()
  before_each(function()
    original_cwd, original_columns, original_lines = vim.fn.getcwd(), vim.o.columns, vim.o.lines
    temporary = vim.fn.tempname() .. "-git-commit"
    vim.fn.mkdir(temporary, "p")
    git("init", "-q")
    vim.api.nvim_set_current_dir(temporary)
    vim.o.columns, vim.o.lines = 180, 50
    message = nil
  end)

  after_each(function()
    vim.cmd "silent only!"
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):find(temporary, 1, true) then vim.api.nvim_buf_delete(buf, { force = true }) end
    end
    vim.api.nvim_set_current_dir(original_cwd)
    vim.o.columns, vim.o.lines = original_columns, original_lines
    vim.fn.delete(temporary, "rf")
  end)

  it("shows a read-only staged diff and status beside the unchanged message, including initial commits", function()
    stage("staged.txt", "staged content")
    vim.fn.writefile({ "untracked content" }, vim.fs.joinpath(temporary, "untracked.txt"))
    local index = git "write-tree"
    open()
    loaded()
    local panes = helpers()
    assert.equals(3, #vim.api.nvim_tabpage_list_wins(0))
    assert.equals(message, vim.api.nvim_get_current_buf())
    assert.same({ "", "# Commit message fixture" }, vim.api.nvim_buf_get_lines(message, 0, -1, false))
    assert(contents(panes["staged.diff"]):find("+staged content", 1, true))
    assert.is_nil(contents(panes["staged.diff"]):find("untracked content", 1, true))
    assert(contents(panes.status):find("untracked.txt", 1, true))
    for _, buf in pairs(panes) do
      assert.is_true(vim.bo[buf].readonly)
      assert.is_false(vim.bo[buf].modifiable)
      assert.is_false(vim.bo[buf].modified)
      assert.is_false(vim.bo[buf].buflisted)
    end
    commit.open(message)
    assert.equals(3, #vim.api.nvim_tabpage_list_wins(0))
    assert.equals(index, git "write-tree")
  end)

  it("uses only a diff below the message in a narrow terminal", function()
    vim.o.columns = 100
    stage("file.txt", "content")
    open "MERGE_MSG"
    loaded()
    assert.equals(2, #vim.api.nvim_tabpage_list_wins(0))
    assert.is_nil(helpers().status)
    local diff_win = vim.fn.bufwinid(helpers()["staged.diff"])
    assert(vim.api.nvim_win_get_position(diff_win)[1] > vim.api.nvim_win_get_position(0)[1])
  end)

  it("distinguishes staged changes from unstaged changes and handles an empty index diff", function()
    stage("file.txt", "original")
    git("commit", "-qm", "Fixture")
    stage("file.txt", "staged")
    vim.fn.writefile({ "unstaged" }, vim.fs.joinpath(temporary, "file.txt"))
    open()
    loaded()
    local diff = contents(helpers()["staged.diff"])
    assert(diff:find("+staged", 1, true))
    assert.is_nil(diff:find("+unstaged", 1, true))
    vim.cmd "enew"
    git("reset", "-q", "HEAD")
    vim.cmd.buffer(message)
    commit.open(message)
    loaded()
    assert(contents(helpers()["staged.diff"]):find("(No staged changes.)", 1, true))
  end)

  it("resolves the correct metadata and index in a linked worktree", function()
    stage("file.txt", "original")
    git("commit", "-qm", "Fixture")
    local worktree = vim.fs.joinpath(temporary, "linked worktree")
    git("worktree", "add", "-qb", "fixture-branch", worktree)
    vim.api.nvim_set_current_dir(worktree)
    vim.fn.writefile({ "worktree content" }, vim.fs.joinpath(worktree, "new.txt"))
    local result = vim.system({ "git", "-C", worktree, "add", "new.txt" }, { text = true }):wait()
    assert.equals(0, result.code, result.stderr)
    local target = vim
      .system({
        "git",
        "-C",
        worktree,
        "rev-parse",
        "--path-format=absolute",
        "--git-path",
        "COMMIT_EDITMSG",
      }, { text = true })
      :wait().stdout
      :gsub("\n$", "")
    vim.fn.writefile({ "" }, target)
    vim.cmd.edit(vim.fn.fnameescape(target))
    message = vim.api.nvim_get_current_buf()
    commit.open(message)
    loaded()
    assert(contents(helpers()["staged.diff"]):find("+worktree content", 1, true))
  end)

  it("ignores ordinary files with a commit-message filename", function()
    local target = vim.fs.joinpath(temporary, "COMMIT_EDITMSG")
    vim.fn.writefile({ "not Git metadata" }, target)
    vim.cmd.edit(vim.fn.fnameescape(target))
    commit.open()
    assert.same({}, helpers())
    assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
  end)

  it("cleans up helpers when leaving the message buffer", function()
    stage("file.txt", "content")
    open()
    vim.cmd "enew"
    assert.same({}, helpers())
    assert.equals(1, #vim.api.nvim_tabpage_list_wins(0))
    vim.wait(100)
    assert.same({}, helpers())
  end)

  it("returns to Git after :wq and commits only staged content", function()
    stage("file.txt", "staged")
    vim.fn.writefile({ "unstaged" }, vim.fs.joinpath(temporary, "file.txt"))
    local result = vim
      .system({ "git", "-C", temporary, "-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit" }, {
        text = true,
        timeout = 10000,
        env = { GIT_EDITOR = editor 'vim.cmd "wq"' },
      })
      :wait()
    assert.equals(0, result.code, result.stderr)
    assert.equals("Commit from editor fixture\n\n", git("log", "-1", "--format=%B"))
    assert.equals("staged\n", git("show", "HEAD:file.txt"))
    assert.same({ "unstaged" }, vim.fn.readfile(vim.fs.joinpath(temporary, "file.txt")))
  end)

  it("returns a failure status on :cq even after writing a nonempty message", function()
    stage("file.txt", "content")
    git("commit", "-qm", "Fixture")
    stage("file.txt", "new content")
    local head, index = git("rev-parse", "HEAD"), git "write-tree"
    local result = vim
      .system({ "git", "-C", temporary, "commit" }, {
        text = true,
        timeout = 10000,
        env = { GIT_EDITOR = editor 'vim.cmd "write"; vim.cmd "cq"' },
      })
      :wait()
    assert.equals(1, result.code, result.stderr)
    assert.equals(head, git("rev-parse", "HEAD"))
    assert.equals(index, git "write-tree")
  end)
end)
