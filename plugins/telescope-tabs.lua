return {
  'LukasPietzschmann/telescope-tabs',
  config = function()
    require('telescope').load_extension 'telescope-tabs'
    require('telescope-tabs').setup {}
  end,
  dependencies = { 'nvim-telescope/telescope.nvim' },
  keys = {
    {
      "<leader>fT",
      "<cmd>Telescope telescope-tabs list_tabs<cr>",
      desc = "Tabs",
    },
    {
      "g<tab>",
      function() require('telescope-tabs').go_to_previous() end,
      desc = "Go to recent tab",
    },
  },
}
