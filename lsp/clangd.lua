-- Load the Compilation database finder as part of Neovim's clangd configuration.
-- Keep this server name so Neovim merges it with the defaults and AstroLSP settings.
return require "clangd.compile-commands"
