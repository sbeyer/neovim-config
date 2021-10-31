-- The following code makes sure packer is installed
local fn = vim.fn
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  use(dofile 'enabled/directory.lua')

  use(dofile 'enabled/git.lua')

  -- Automatically set up your configuration after cloning packer.nvim
  -- Keep this at the end after all plugins
  if packer_bootstrap then
    require('packer').sync()
  end
end)
