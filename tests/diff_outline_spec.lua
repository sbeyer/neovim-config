local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

vim.opt.rtp:prepend(vim.fn.getcwd())
local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "aerial.nvim" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
local aerial = require "aerial"
local opts = dofile("lua/plugins/aerial.lua").opts
aerial.setup(vim.tbl_deep_extend("force", opts, { backends = { "treesitter" }, filter_kind = false }))
aerial.sync_load()

local buffer
local patch = {
  "diff --git a/first.cpp b/first.cpp",
  "index 1234567..abcdef0 100644",
  "--- a/first.cpp",
  "+++ b/first.cpp",
  "@@ -1,2 +1,2 @@ int first()",
  "-old",
  "+new",
  " context",
  "@@ -10,2 +10,2 @@ int second()",
  "-old",
  "+new",
  " context",
  "diff --git a/second.lua b/second.lua",
  "index 1234567..abcdef0 100644",
  "--- a/second.lua",
  "+++ b/second.lua",
  "@@ -1 +1 @@",
  "-old",
  "+new",
}

local function symbols(lines)
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
  vim.bo[buffer].filetype = "diff"
  require("aerial.backends.treesitter").fetch_symbols_sync(buffer)
  return require("aerial.data").get_or_create(buffer).items
end

describe("Diff outline", function()
  before_each(function()
    buffer = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_set_current_buf(buffer)
  end)

  after_each(function() vim.api.nvim_buf_delete(buffer, { force = true }) end)

  it("lists file headers with their hunks nested underneath", function()
    local items = symbols(patch)
    assert.equals(2, #items)
    assert.equals(patch[1], items[1].name)
    assert.equals(patch[13], items[2].name)
    assert.equals(2, #items[1].children)
    assert.equals(1, #items[2].children)
    assert.equals(patch[5], items[1].children[1].name)
    assert.equals(patch[9], items[1].children[2].name)
    assert.equals(patch[17], items[2].children[1].name)
    assert.equals(items[1], items[1].children[1].parent)
    assert.equals(items[2], items[2].children[1].parent)
  end)

  it("jumps to the selected file or hunk header in the diff buffer", function()
    symbols(patch)
    for index, line in ipairs { 1, 5, 9, 13, 17 } do
      aerial.select { index = index }
      assert.equals(buffer, vim.api.nvim_get_current_buf())
      assert.same({ line, 0 }, vim.api.nvim_win_get_cursor(0))
    end
  end)

  it("groups hunks under files when blank lines replace index metadata", function()
    local lines = vim.deepcopy(patch)
    lines[2], lines[14] = "", ""
    local items = symbols(lines)
    assert.equals(2, #items)
    assert.equals(2, #items[1].children)
    assert.equals(1, #items[2].children)
    assert.equals(lines[5], items[1].children[1].name)
    assert.equals(lines[17], items[2].children[1].name)
    assert.equals(items[1], items[1].children[1].parent)
    assert.equals(1, items[1].children[1].level)
    assert.equals(12, items[1].end_lnum)
    assert.equals(8, items[1].children[1].end_lnum)
    aerial.select { index = 2 }
    assert.same({ 5, 0 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("keeps renamed and binary files visible even when they have no hunks", function()
    local lines = {
      "diff --git a/old.txt b/new.txt",
      "similarity index 100%",
      "rename from old.txt",
      "rename to new.txt",
      "diff --git a/image.png b/image.png",
      "index 1234567..abcdef0 100644",
      "Binary files a/image.png and b/image.png differ",
    }
    local items = symbols(lines)
    assert.equals(2, #items)
    assert.equals(lines[1], items[1].name)
    assert.equals(lines[5], items[2].name)
    assert.is_nil(items[1].children)
    assert.is_nil(items[2].children)
  end)
end)
