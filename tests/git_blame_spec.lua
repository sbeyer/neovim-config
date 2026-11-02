local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "astroui", "gitsigns.nvim" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
vim.g.mapleader = " "
require("astrocore").setup { features = { notifications = false } }
local opts = dofile(vim.fs.joinpath(lazy, "AstroNvim/lua/astronvim/plugins/gitsigns.lua")).opts(nil, {})
dofile("lua/plugins/gitsigns.lua").opts(nil, opts)
opts.gh = false
require("gitsigns").setup(opts)
local temporary, buffer

local function git(...)
  local result = vim
    .system(
      vim.list_extend({
        "git",
        "-C",
        temporary,
        "-c",
        "user.name=Test",
        "-c",
        "user.email=test@example.invalid",
      }, { ... }),
      { text = true }
    )
    :wait()
  assert.equals(0, result.code, result.stderr)
end

describe("Consolidated Git blame", function()
  before_each(function()
    temporary = vim.fn.tempname() .. "-git-blame"
    vim.fn.mkdir(temporary, "p")
    git("init", "-q")
    local path = vim.fs.joinpath(temporary, "file.txt")
    vim.fn.writefile({ "original line" }, path)
    git("add", "file.txt")
    git("commit", "-qm", "Initial fixture")
    vim.fn.writefile({ "committed replacement" }, path)
    git("commit", "-qam", "Fixture subject", "-m", "Full message body for blame")
    vim.cmd.edit(vim.fn.fnameescape(path))
    buffer = vim.api.nvim_get_current_buf()
    assert(vim.wait(5000, function() return vim.fn.maparg(" gl", "n") ~= "" end))
  end)

  after_each(function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_config(win).relative ~= "" then vim.api.nvim_win_close(win, true) end
    end
    require("gitsigns").detach(buffer)
    vim.api.nvim_buf_delete(buffer, { force = true })
    vim.fn.delete(temporary, "rf")
  end)

  it("shows the full message and relevant hunk through gl, removes gL, and retains other Git mappings", function()
    vim.fn.feedkeys(" gl", "xt")
    assert(vim.wait(5000, function()
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_config(win).relative ~= "" then
          local text = table.concat(vim.api.nvim_buf_get_lines(vim.api.nvim_win_get_buf(win), 0, -1, false), "\n")
          if text:find("Full message body for blame", 1, true) and text:find("+committed replacement", 1, true) then
            return true
          end
        end
      end
      return false
    end))
    vim.api.nvim_set_current_buf(buffer)
    assert.same({}, vim.fn.maparg(" gL", "n", false, true))
    assert.equals("Stage/Unstage Git hunk", vim.fn.maparg(" gs", "n", false, true).desc)
    assert.equals("Preview Git hunk", vim.fn.maparg(" gp", "n", false, true).desc)
  end)
end)
