local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each
local path = dofile("lua/plugins/astrocore.lua").opts.options.opt.path
local temporary, original_cwd, original_path, original_hidden

local function write(name, lines)
  local filename = vim.fs.joinpath(temporary, name)
  vim.fn.mkdir(vim.fs.dirname(filename), "p")
  vim.fn.writefile(lines or {}, filename)
  return filename
end

local function open_reference(file, reference)
  local filename = vim.fs.joinpath(temporary, file)
  if vim.api.nvim_buf_get_name(0) ~= filename then vim.cmd.edit(filename) end
  vim.bo.path = path
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { reference })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function follow(expected, command)
  vim.cmd.normal { command or "gf", bang = true }
  assert.equals(vim.fs.joinpath(temporary, expected), vim.api.nvim_buf_get_name(0))
end

describe("Native gf file lookup", function()
  before_each(function()
    original_cwd, original_path, original_hidden = vim.fn.getcwd(), vim.o.path, vim.o.hidden
    temporary = vim.fn.tempname() .. "-file-navigation"
    write "a/b/c/d/file"
    vim.api.nvim_set_current_dir(vim.fs.joinpath(temporary, "a/b/c"))
    vim.o.hidden = true
  end)

  after_each(function()
    vim.api.nvim_set_current_dir(original_cwd)
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_get_name(buf):sub(1, #temporary + 1) == temporary .. "/" then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
    vim.o.path, vim.o.hidden = original_path, original_hidden
    vim.fn.delete(temporary, "rf")
  end)

  for _, reference in ipairs { "e/foo", "foo" } do
    it("prefers " .. reference .. " beside the file, with cwd as fallback", function()
      write("a/b/c/d/" .. reference)
      write("a/b/c/" .. reference)
      open_reference("a/b/c/d/file", reference)
      follow("a/b/c/d/" .. reference)
      vim.fn.delete(vim.fs.joinpath(temporary, "a/b/c/d/" .. reference))
      open_reference("a/b/c/d/file", reference)
      follow("a/b/c/" .. reference)
    end)
  end

  for _, reference in ipairs { "e/bar", "d/e/bar", "c/d/e/bar", "b/c/d/e/bar" } do
    it("finds overlapping ancestor directories in " .. reference, function()
      write "a/b/c/d/e/foo"
      write "a/b/c/d/e/bar"
      vim.api.nvim_set_current_dir(vim.fs.joinpath(temporary, "a/b/c/d/e"))
      open_reference("a/b/c/d/e/foo", reference)
      follow "a/b/c/d/e/bar"
    end)
  end

  it("searches the file's ancestors even when cwd is unrelated", function()
    write "a/b/bar"
    vim.fn.mkdir(vim.fs.joinpath(temporary, "unrelated"), "p")
    vim.api.nvim_set_current_dir(vim.fs.joinpath(temporary, "unrelated"))
    open_reference("a/b/c/d/file", "bar")
    follow "a/b/bar"
  end)

  it("preserves absolute references, suffix lookup, and jump-back navigation", function()
    local target = write "a/b/c/d/target.h"
    open_reference("a/b/c/d/file", target)
    follow "a/b/c/d/target.h"
    vim.cmd.normal { vim.api.nvim_replace_termcodes("<C-o>", true, false, true), bang = true }
    assert.equals(vim.fs.joinpath(temporary, "a/b/c/d/file"), vim.api.nvim_buf_get_name(0))
    open_reference("a/b/c/d/file", "target")
    vim.bo.suffixesadd = ".h"
    follow "a/b/c/d/target.h"
  end)
end)
