return {
  plugins = {
    -- Paq manages itself
    "savq/paq-nvim";

    -- file:line:col support
    'wsdjeg/vim-fetch';

    -- better tree-sitter support,
    -- don't forget :TSInstall cpp, rust, etc
    -- and :TSUpdate
    {'nvim-treesitter/nvim-treesitter', branch="0.5-compat"};
    -- :TSPlaygroundToggle just for fun, but not really necessary
    -- 'nvim-treesitter/playground';

    -- easy LSP configuration
    'neovim/nvim-lspconfig';

    -- CamelCase motions (like word motions but in CamelCase)
    'bkad/CamelCaseMotion';

    -- Multi-entry selection UI.
    -- :Files, <F1>, :Rg, :RG etc
    'junegunn/fzf';
    'junegunn/fzf.vim';
    -- install fzf and ripgrep on your system! And maybe bat (for syntax highlighting in previews)

    -- run a heuristic to guess indentation settings
    'tpope/vim-sleuth';

    -- make space-based indentations visible
    'Yggdroot/indentLine';

    -- Track the engine.
    'SirVer/ultisnips';

    -- Snippets are separated from the engine. Add this if you want them:
    'honza/vim-snippets';

    -- autocompletion
    'hrsh7th/cmp-nvim-lsp';
    'hrsh7th/cmp-buffer';
    'hrsh7th/nvim-cmp';
    -- ...for ultisnips
    'quangnguyen30192/cmp-nvim-ultisnips';
  };

  config = function() end
}
