---@type vim.lsp.Config
return {
  settings = { xml = {} },
  before_init = function(_, config)
    local root = config.root_dir
    local settings = require("vscode.settings").read(root)
    local associations = {}
    local configured = settings["xml.fileAssociations"]
    for _, association in ipairs(type(configured) == "table" and configured or {}) do
      if
        type(association) == "table"
        and type(association.pattern) == "string"
        and type(association.systemId) == "string"
      then
        local resolved = vim.deepcopy(association)
        for _, key in ipairs { "pattern", "systemId" } do
          resolved[key] = resolved[key]:gsub("%${workspaceFolder}", function() return root end)
        end
        if
          not vim.startswith(resolved.systemId, "/")
          and not resolved.systemId:match "^[%a][%w+.-]*:"
          and not resolved.systemId:find "%${"
        then
          resolved.systemId = vim.fs.joinpath(root, resolved.systemId)
        end
        table.insert(associations, resolved)
      end
    end
    config.settings.xml.fileAssociations = associations
  end,
}
