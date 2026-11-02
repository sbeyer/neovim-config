local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

vim.opt.rtp:prepend(vim.fn.getcwd())
local remove = require "git.remove"
local temporary, buffer, selection, grep, deleted, notifications
local original_select, original_notify, original_snacks

local function git(...)
  local result =
    vim.system(vim.list_extend({ "git", "--literal-pathspecs", "-C", temporary }, { ... }), { text = true }):wait()
  assert.equals(0, result.code, result.stderr)
  return result.stdout
end

local function fixture(filename)
  local path = vim.fs.joinpath(temporary, filename or "current.txt")
  vim.fn.writefile({ "original" }, path)
  git("add", "--", vim.fs.basename(path))
  git("-c", "user.name=Test", "-c", "user.email=test@example.invalid", "commit", "-qm", "Fixture")
  buffer = vim.fn.bufadd(path)
  vim.fn.bufload(buffer)
  vim.api.nvim_set_current_buf(buffer)
  return path
end

local function choose(index)
  local pending = selection
  assert.is_not_nil(pending)
  selection = nil
  pending.callback(index and pending.items[index] or nil)
end

describe("Reviewed Git file removal", function()
  before_each(function()
    temporary = vim.fn.tempname() .. "-git-remove"
    vim.fn.mkdir(temporary, "p")
    git("init", "-q")
    original_select, original_notify = vim.ui.select, vim.notify
    original_snacks = package.loaded.snacks
    selection, grep, deleted, notifications = nil, nil, {}, {}
    vim.ui.select = function(items, opts, callback) selection = { items = items, opts = opts, callback = callback } end
    vim.notify = function(message, level) table.insert(notifications, { message = message, level = level }) end
    package.loaded.snacks = {
      bufdelete = function(opts)
        assert.is_true(opts.force)
        table.insert(deleted, opts.buf)
        vim.api.nvim_buf_delete(opts.buf, { force = true })
      end,
      picker = {
        grep = function(opts)
          for _, buf in ipairs(deleted) do
            assert.is_false(vim.api.nvim_buf_is_loaded(buf))
          end
          grep = opts
        end,
      },
    }
  end)

  after_each(function()
    vim.ui.select, vim.notify = original_select, original_notify
    package.loaded.snacks = original_snacks
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.startswith(vim.api.nvim_buf_get_name(buf), temporary .. "/") then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
    vim.fn.delete(temporary, "rf")
  end)

  it("defaults to cancellation and leaves edits, index, and disk unchanged on cancellation or dismissal", function()
    local path = fixture()
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "unsaved" })
    for _, index in ipairs { 1, 0 } do
      remove.current()
      assert.equals("Cancel", selection.opts.format_item(selection.items[1]))
      assert(selection.opts.prompt:find("unsaved buffer: yes; staged: no; unstaged: no", 1, true))
      choose(index ~= 0 and index or nil)
      assert.same({ "original" }, vim.fn.readfile(path))
      assert.equals("", git("diff", "--cached"))
      assert.is_true(vim.bo[buffer].modified)
      assert.same({}, deleted)
      assert.is_nil(grep)
    end
  end)

  it(
    "warns about all edits, force-removes only the literal path, closes its buffer, then searches references",
    function()
      local path = fixture ":(glob)* [x]; file.txt"
      local decoy = vim.fs.joinpath(temporary, "another file.txt")
      vim.fn.writefile({ "keep" }, decoy)
      vim.fn.writefile({ "staged" }, path)
      git("add", "--", vim.fs.basename(path))
      vim.fn.writefile({ "unstaged" }, path)
      vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "unsaved" })
      remove.current()
      assert(selection.opts.prompt:find("unsaved buffer: yes; staged: yes; unstaged: yes", 1, true))
      assert.is_nil(grep)
      assert.equals(1, vim.fn.filereadable(path))
      choose(2)
      assert.equals(0, vim.fn.filereadable(path))
      assert.same({ "keep" }, vim.fn.readfile(decoy))
      assert.equals("", git("ls-files", "--", vim.fs.basename(path)))
      assert.equals("D", git("diff", "--cached", "--name-status"):sub(1, 1))
      assert.same({ buffer }, deleted)
      assert.equals(temporary, grep.cwd)
      assert.equals(vim.fs.basename(path), grep.search)
      assert.is_false(grep.regex)
      assert.is_true(grep.hidden)
    end
  )

  it("force-untracks while keeping disk contents and unsaved buffer edits", function()
    local path = fixture()
    vim.fn.writefile({ "staged" }, path)
    git("add", "--", "current.txt")
    vim.fn.writefile({ "unstaged" }, path)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, { "unsaved" })
    remove.current()
    choose(3)
    assert.same({ "unstaged" }, vim.fn.readfile(path))
    assert.same({ "unsaved" }, vim.api.nvim_buf_get_lines(buffer, 0, -1, false))
    assert.is_true(vim.bo[buffer].modified)
    assert.equals("", git("ls-files", "--", "current.txt"))
    assert.same({}, deleted)
    assert.equals("current.txt", grep.search)
  end)

  it("keeps the original target when focus changes while choosing an operation", function()
    local path = fixture()
    remove.current()
    local other = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_buf_set_name(other, vim.fs.joinpath(temporary, "other.txt"))
    vim.api.nvim_set_current_buf(other)
    vim.api.nvim_buf_set_lines(other, 0, -1, false, { "keep" })
    choose(2)
    assert.equals(0, vim.fn.filereadable(path))
    assert.same({ buffer }, deleted)
    assert.same({ "keep" }, vim.api.nvim_buf_get_lines(other, 0, -1, false))
  end)

  it("escapes filenames containing Snacks' grep-argument separator", function()
    fixture "file -- flags.txt"
    remove.current()
    choose(3)
    assert.equals([[file \-\- flags\.txt]], grep.search)
    assert.is_true(grep.regex)
  end)

  it("leaves the buffer open and does not search when Git refuses the operation", function()
    local path = fixture()
    remove.current()
    vim.fn.writefile({}, vim.fs.joinpath(temporary, ".git", "index.lock"))
    choose(2)
    assert.equals(1, vim.fn.filereadable(path))
    assert.is_true(vim.api.nvim_buf_is_loaded(buffer))
    assert.same({}, deleted)
    assert.is_nil(grep)
    assert.equals(vim.log.levels.ERROR, notifications[1].level)
    assert(notifications[1].message:find("Git removal failed:", 1, true))
  end)

  it("rejects untracked and unnamed buffers without offering removal", function()
    local path = vim.fs.joinpath(temporary, "untracked.txt")
    vim.fn.writefile({ "keep" }, path)
    buffer = vim.fn.bufadd(path)
    vim.fn.bufload(buffer)
    vim.api.nvim_set_current_buf(buffer)
    remove.current()
    assert.is_nil(selection)
    assert.equals(1, vim.fn.filereadable(path))
    vim.api.nvim_set_current_buf(vim.api.nvim_create_buf(true, false))
    remove.current()
    assert.is_nil(selection)
    assert.equals(2, #notifications)
    assert.is_nil(grep)
  end)
end)
