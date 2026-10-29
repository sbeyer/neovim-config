-- Compilation database finder: select a database for clangd through Neovim's LSP configuration.
-- Search the project root, build-x86_64/, and build*/.
-- Prompt when several distinct databases exist, deduplicating symlinks, and reuse the choice.
-- Cancelling the picker selects the first database.
-- Report missing databases through the notification UI while retaining clangd's fallback.

local projects = {}

---@type vim.lsp.Config
return {
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, ".git") or vim.fs.root(bufnr, vim.lsp.config.clangd.root_markers) or vim.fn.getcwd()
    local project = projects[root]
    if project then
      if project.waiting then
        table.insert(project.waiting, on_dir)
      else
        on_dir(root)
      end
      return
    end

    project = { waiting = { on_dir } }
    projects[root] = project
    local function start(directory)
      project.directory = directory
      local waiting = project.waiting
      project.waiting = nil
      for _, callback in ipairs(waiting) do
        callback(root)
      end
    end

    local directories, seen = {}, {}
    local function add_database(directory)
      local path = vim.fs.joinpath(directory, "compile_commands.json")
      local resolved = vim.uv.fs_realpath(path)
      if resolved and not seen[resolved] and vim.fn.filereadable(path) == 1 then
        seen[resolved] = true
        table.insert(directories, directory)
      end
    end

    for _, directory in ipairs { root, vim.fs.joinpath(root, "build-x86_64") } do
      add_database(directory)
    end

    local builds = {}
    for name in vim.fs.dir(root) do
      if vim.startswith(name, "build") then table.insert(builds, name) end
    end
    table.sort(builds)
    for _, name in ipairs(builds) do
      add_database(vim.fs.joinpath(root, name))
    end

    if #directories == 0 then
      vim.schedule(
        function()
          vim.notify(
            "No compile_commands.json found in " .. root .. " or its build*/ directories.",
            vim.log.levels.ERROR,
            { title = "clangd" }
          )
        end
      )
      return start()
    end
    if #directories == 1 then return start(directories[1]) end
    -- Let :edit finish restoring its window before the picker takes focus.
    vim.schedule(function()
      vim.ui.select(directories, {
        prompt = "clangd: choose compilation database",
        format_item = function(directory)
          return directory == root and "compile_commands.json" or vim.fs.basename(directory) .. "/compile_commands.json"
        end,
      }, function(directory) start(directory or directories[1]) end)
    end)
  end,
  before_init = function(params, config)
    local project = projects[config.root_dir]
    if project and project.directory then
      -- clangd accepts one database directory through its initialization options.
      params.initializationOptions = params.initializationOptions or {}
      params.initializationOptions.compilationDatabasePath = project.directory
    end
  end,
}
