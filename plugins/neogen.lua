local pNeogen = "<leader>a"

return {
  -- annotation generation
  {
    'danymat/neogen',
    dependencies = "nvim-treesitter/nvim-treesitter",
    cmd = "Neogen",
    config = function()
      require("neogen").setup {
        snippet_engine = "luasnip",
        languages = {
          lua = require('neogen.configurations.lua'),
              ['c.doxygen'] = require('neogen.configurations.c'),
              ['cpp.doxygen'] = require('neogen.configurations.cpp'),
          rust = require('neogen.configurations.rust'),
        },
      }
    end,
    keys = {
      {
        pNeogen,
        desc = "Annotate ...",
      },
      {
        pNeogen .. "<cr>",
        function() require("neogen").generate() end,
        desc = "Current",
      },
      {
        pNeogen .. "c",
        function() require("neogen").generate { type = "class" } end,
        desc = "Class",
      },
      {
        pNeogen .. "f",
        function() require("neogen").generate { type = "func" } end,
        desc = "Function",
      },
      {
        pNeogen .. "t",
        function() require("neogen").generate { type = "type" } end,
        desc = "Type",
      },
      {
        pNeogen .. "F",
        function() require("neogen").generate { type = "file" } end,
        desc = "File",
      },
    }
  },
}
