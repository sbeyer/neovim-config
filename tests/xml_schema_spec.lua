local busted = require "plenary.busted"
local describe, it = busted.describe, busted.it
local before_each, after_each = busted.before_each, busted.after_each

local lazy = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
for _, plugin in ipairs { "LuaSnip", "nvim-lspconfig" } do
  vim.opt.rtp:append(vim.fs.joinpath(lazy, plugin))
end
vim.cmd "filetype on"
local executable = vim.fs.joinpath(vim.fn.stdpath "data", "mason", "bin", "lemminx")
local temporary, buffers, published

local function write(path, lines)
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.fn.writefile(lines, path)
end

local function repository(name, child)
  local root = vim.fs.joinpath(temporary, name)
  vim.fn.mkdir(vim.fs.joinpath(root, ".git"), "p")
  write(vim.fs.joinpath(root, ".vscode", "settings.json"), {
    vim.json.encode {
      ["xml.fileAssociations"] = {
        { pattern = "**/*.xml", systemId = "${workspaceFolder}/schemas/greeting.xsd" },
      },
    },
  })
  write(vim.fs.joinpath(root, "schemas", "greeting.xsd"), {
    '<xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">',
    '  <xs:element name="greeting">',
    "    <xs:complexType><xs:sequence>",
    '      <xs:element name="' .. child .. '" type="xs:string"/>',
    "    </xs:sequence></xs:complexType>",
    "  </xs:element>",
    "</xs:schema>",
  })
  return root
end

local function configure()
  assert.equals(1, vim.fn.executable(executable), "Install LemMinX through Mason before running XML LSP tests")
  vim.lsp.config("lemminx", {
    cmd = { executable },
    handlers = {
      ["textDocument/publishDiagnostics"] = function(err, result, context, config)
        published[result.uri] = result.diagnostics
        vim.lsp.handlers["textDocument/publishDiagnostics"](err, result, context, config)
      end,
    },
  })
  vim.lsp.enable "lemminx"
end

local function open(root, lines)
  local path = vim.fs.joinpath(root, "greeting.xml")
  write(path, lines)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local buffer = vim.api.nvim_get_current_buf()
  table.insert(buffers, buffer)
  assert(
    vim.wait(15000, function()
      for _, client in ipairs(vim.lsp.get_clients { name = "lemminx", bufnr = buffer }) do
        if client.initialized then return true end
      end
    end, 50),
    "LemMinX did not attach"
  )
  assert(
    vim.wait(15000, function() return published[vim.uri_from_bufnr(buffer)] ~= nil end, 50),
    "No XML diagnostics received"
  )
  return buffer, vim.lsp.get_clients({ name = "lemminx", bufnr = buffer })[1]
end

describe("Repository-local XML schemas", function()
  before_each(function()
    temporary = vim.fn.tempname() .. "-xml-schema"
    vim.fn.mkdir(temporary, "p")
    buffers, published = {}, {}
  end)

  after_each(function()
    vim.lsp.enable("lemminx", false)
    local clients = vim.lsp.get_clients { name = "lemminx" }
    for _, client in ipairs(clients) do
      client:stop(true)
    end
    vim.wait(3000, function()
      for _, client in ipairs(clients) do
        if vim.lsp.get_client_by_id(client.id) then return false end
      end
      return true
    end, 50)
    for _, buffer in ipairs(buffers) do
      vim.api.nvim_buf_delete(buffer, { force = true })
    end
    vim.fn.delete(temporary, "rf")
  end)

  it("resolves workspace and relative schema paths without mutating shared settings or other XML options", function()
    local root = repository("first", "name")
    write(vim.fs.joinpath(root, ".vscode", "settings.json"), {
      vim.json.encode {
        ["xml.fileAssociations"] = {
          { pattern = "${workspaceFolder}/**/*.xml", systemId = "${workspaceFolder}/schemas/greeting.xsd" },
          { pattern = "*.other", systemId = "schemas/greeting.xsd" },
          { pattern = "*.remote", systemId = "https://example.invalid/schema.xsd" },
          { pattern = "*.invalid", systemId = false },
          false,
        },
      },
    })
    local config = dofile "lsp/lemminx.lua"
    config.root_dir = root
    config.settings.xml.format = { enabled = false }
    config.before_init({}, config)
    local associations = config.settings.xml.fileAssociations
    assert.equals(3, #associations)
    assert.equals(root .. "/**/*.xml", associations[1].pattern)
    assert.equals(root .. "/schemas/greeting.xsd", associations[1].systemId)
    assert.equals(root .. "/schemas/greeting.xsd", associations[2].systemId)
    assert.equals("https://example.invalid/schema.xsd", associations[3].systemId)
    assert.is_false(config.settings.xml.format.enabled)
    assert.equals(
      "${workspaceFolder}/schemas/greeting.xsd",
      require("vscode.settings").read(root)["xml.fileAssociations"][1].systemId
    )
  end)

  it("validates XML and completes elements using an external schema without XML schema declarations", function()
    local root = repository("first", "name")
    configure()
    local buffer, client = open(root, { "<greeting>", "  <wrong/>", "</greeting>" })
    local messages = vim.tbl_map(function(diagnostic) return diagnostic.message end, vim.diagnostic.get(buffer))
    assert.is_not_nil(table.concat(messages, "\n"):find("wrong", 1, true))
    vim.api.nvim_buf_set_lines(buffer, 1, 2, false, { "  <" })
    local response = client:request_sync("textDocument/completion", {
      textDocument = { uri = vim.uri_from_bufnr(buffer) },
      position = { line = 1, character = 3 },
    }, 10000, buffer)
    assert.is_not_nil(response)
    assert.is_nil(response.err)
    local found = false
    for _, item in ipairs(response.result.items or response.result) do
      if item.label == "name" or item.label == "<name>" then found = true end
    end
    assert.is_true(found, "Schema element was missing from completion")
  end)

  it("uses separate clients and schemas for different repositories without leaking associations", function()
    local first, second = repository("first", "name"), repository("second", "message")
    configure()
    local first_buffer, first_client = open(first, { "<greeting><message>Hello</message></greeting>" })
    local second_buffer, second_client = open(second, { "<greeting><message>Hello</message></greeting>" })
    assert.is_not.equals(first_client.id, second_client.id)
    assert.equals(first .. "/schemas/greeting.xsd", first_client.settings.xml.fileAssociations[1].systemId)
    assert.equals(second .. "/schemas/greeting.xsd", second_client.settings.xml.fileAssociations[1].systemId)
    assert.is_true(#vim.diagnostic.get(first_buffer) > 0)
    assert.same({}, vim.diagnostic.get(second_buffer))
  end)
end)
