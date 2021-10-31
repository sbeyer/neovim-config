-- The following code makes sure packer is installed
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Iterate over the "enabled" directory and use their package declarations
  local decl_path = fn.stdpath('config') .. '/enabled/'
  local decl_files = fn.split(fn.globpath(decl_path, '*.lua'), '\n')
  local declarations = {}
  for _, decl_file in pairs(decl_files) do
    table.insert(declarations, dofile(decl_file))
  end
  for _, decl in pairs(declarations) do
    use(decl)
  end

  -- Get old declarations of packer-decls.txt to check if we need to sync
  local old_decl_file = fn.stdpath('config') .. '/plugin/packer-decls.txt'
  local old_declaration_string = table.concat(vim.fn.readfile(old_decl_file), '\n')
  local new_declaration_string = vim.inspect(declarations)

  -- Set up your configuration after cloning packer.nvim or changing declarations
  if packer_bootstrap or new_declaration_string ~= old_declaration_string then
    require('packer').sync()

    vim.fn.writefile({ new_declaration_string }, old_decl_file)
  end
end)
