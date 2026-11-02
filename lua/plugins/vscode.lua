---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts.autocmds.vscode_file_associations = {
      {
        event = { "BufNew", "BufReadPre" },
        desc = "Register repository-local VS Code file associations before filetype detection",
        callback = function(event) require("vscode.associations").register(event.buf) end,
      },
    }
    -- Command-line buffers can exist before these autocmds are installed.
    for _, buffer in ipairs(vim.api.nvim_list_bufs()) do
      require("vscode.associations").register(buffer)
    end
  end,
}
