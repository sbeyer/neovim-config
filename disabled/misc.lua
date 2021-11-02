return {
  plugins = {
    -- better tree-sitter support,
    -- don't forget :TSInstall cpp, rust, etc
    -- and :TSUpdate
    {'nvim-treesitter/nvim-treesitter', branch="0.5-compat"};
    -- :TSPlaygroundToggle just for fun, but not really necessary
    -- 'nvim-treesitter/playground';

    -- Multi-entry selection UI.
    -- :Files, <F1>, :Rg, :RG etc
    'junegunn/fzf';
    'junegunn/fzf.vim';
    -- install fzf and ripgrep on your system! And maybe bat (for syntax highlighting in previews)

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
