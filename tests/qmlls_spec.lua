local busted = require "plenary.busted"
local describe, it, pending = busted.describe, busted.it, busted.pending
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "astrocore", "astrolsp", "nvim-lspconfig", "nvim-treesitter" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
local settings = require "config"
local astrolsp = require "astrolsp"
local original_lsp_config = vim.deepcopy(astrolsp.config)
dofile("lua/plugins/treesitter.lua").init()
local core_opts = dofile("lua/plugins/astrocore.lua").opts
require("astrocore").setup {
  features = { notifications = false },
  filetypes = core_opts.filetypes,
  autocmds = { qmlls_path_check = core_opts.autocmds.qmlls_path_check },
}
vim.cmd "filetype on"

local temporary, buffer, original_path, original_notify, notifications

local function flush()
  local done = false
  vim.schedule(function() done = true end)
  assert(vim.wait(1000, function() return done end))
end

local function configure() astrolsp.setup(dofile("lua/plugins/astrolsp.lua").opts) end

local function open_qml()
  local path = vim.fs.joinpath(temporary, "Example.qml")
  vim.fn.writefile({ "import QtQuick", "Item {", "    width: 100", "    height: 100", "}" }, path)
  vim.cmd.edit(vim.fn.fnameescape(path))
  buffer = vim.api.nvim_get_current_buf()
end

local function attached_client()
  assert(vim.fn.executable(settings.qmlls_path) == 1, "qmlls_path is not executable: " .. settings.qmlls_path)
  assert(
    vim.wait(15000, function()
      for _, client in ipairs(vim.lsp.get_clients { name = "qmlls", bufnr = buffer }) do
        if client.initialized then return true end
      end
    end, 50),
    "qmlls did not attach"
  )
  return vim.lsp.get_clients({ name = "qmlls", bufnr = buffer })[1]
end

describe("QML language server", function()
  before_each(function()
    original_path = settings.qmlls_path
    original_notify, notifications = vim.notify, {}
    vim.notify = function(message, level, opts)
      notifications[#notifications + 1] = { message = message, level = level, title = opts and opts.title }
    end
    astrolsp.config = vim.deepcopy(original_lsp_config)
    temporary = vim.fn.tempname() .. "-qmlls-tests"
    vim.fn.mkdir(vim.fs.joinpath(temporary, ".git"), "p")
  end)

  after_each(function()
    settings.qmlls_path = original_path
    vim.lsp.enable("qmlls", false)
    local clients = vim.lsp.get_clients { name = "qmlls" }
    for _, client in ipairs(clients) do
      client:stop(true)
    end
    vim.wait(3000, function()
      for _, client in ipairs(clients) do
        if vim.lsp.get_client_by_id(client.id) then return false end
      end
      return true
    end, 50)
    if buffer and vim.api.nvim_buf_is_valid(buffer) then vim.api.nvim_buf_delete(buffer, { force = true }) end
    buffer = nil
    astrolsp.config = vim.deepcopy(original_lsp_config)
    vim.fn.delete(temporary, "rf")
    flush()
    vim.notify = original_notify
  end)

  it("parses and highlights native QML buffers with the qmljs parser", function()
    open_qml()
    assert.equals("qml", vim.bo[buffer].filetype)
    local parser = vim.treesitter.get_parser(buffer)
    assert.equals("qmljs", parser:lang())
    assert.is_false(parser:parse()[1]:root():has_error())
    vim.treesitter.start(buffer)
    assert.is_not_nil(vim.treesitter.highlighter.active[buffer])
  end)

  it("does not enable or attach qmlls when the configured path is empty", function()
    settings.qmlls_path = ""
    configure()
    open_qml()
    flush()
    assert.equals("qml", vim.bo[buffer].filetype)
    assert.is_false(vim.lsp.is_enabled "qmlls")
    assert.same({}, vim.lsp.get_clients { name = "qmlls", bufnr = buffer })
    assert.same({}, notifications)
  end)

  for _, case in ipairs { "missing", "non-executable" } do
    it("warns when opening QML with a " .. case .. " server path", function()
      settings.qmlls_path = vim.fs.joinpath(temporary, "unavailable qmlls")
      if case == "non-executable" then
        vim.fn.writefile({ "not an executable" }, settings.qmlls_path)
        assert.equals(1, vim.fn.setfperm(settings.qmlls_path, "rw-------"))
      end
      open_qml()
      flush()
      assert.equals(1, #notifications)
      local warning = notifications[1]
      assert.equals(vim.log.levels.WARN, warning.level)
      assert.equals("qmlls", warning.title)
      assert(warning.message:find(settings.qmlls_path, 1, true))
      assert(warning.message:find("lua/config.lua", 1, true))
      assert(warning.message:find('qmlls_path to ""', 1, true))
    end)
  end

  it("does not warn for an executable path", function()
    settings.qmlls_path = vim.v.progpath
    open_qml()
    flush()
    assert.same({}, notifications)
  end)

  it("does not warn for non-QML files even when the path is invalid", function()
    settings.qmlls_path = vim.fs.joinpath(temporary, "missing-qmlls")
    local path = vim.fs.joinpath(temporary, "notes.txt")
    vim.fn.writefile({ "ordinary text" }, path)
    vim.cmd.edit(vim.fn.fnameescape(path))
    buffer = vim.api.nvim_get_current_buf()
    flush()
    assert.same({}, notifications)
  end)

  local integration = settings.qmlls_path ~= "" and it or pending
  local reason = integration == pending and " (skipped: qmlls_path is empty)" or ""

  integration(
    "attaches to QML files using the configured executable and provides QtQuick completion" .. reason,
    function()
      configure()
      open_qml()
      local client = attached_client()
      assert.equals("qml", vim.bo[buffer].filetype)
      assert.same({ settings.qmlls_path, "--no-cmake-calls" }, client.config.cmd)
      local response = client:request_sync("textDocument/completion", {
        textDocument = { uri = vim.uri_from_bufnr(buffer) },
        position = { line = 2, character = 4 },
      }, 10000, buffer)
      assert.is_not_nil(response)
      assert.is_nil(response.err)
      local labels = {}
      for _, item in ipairs(response.result.items or response.result) do
        labels[item.label] = true
      end
      assert.is_true(labels.width)
    end
  )

  integration("reports diagnostics for an invalid QML property after attachment" .. reason, function()
    configure()
    open_qml()
    attached_client()
    vim.api.nvim_buf_set_lines(buffer, 3, 4, false, { "    unknownProperty: true" })
    assert(
      vim.wait(15000, function()
        for _, diagnostic in ipairs(vim.diagnostic.get(buffer)) do
          if diagnostic.message:find("unknownProperty", 1, true) then return true end
        end
      end, 50),
      "qmlls did not report the invalid property"
    )
  end)
end)
