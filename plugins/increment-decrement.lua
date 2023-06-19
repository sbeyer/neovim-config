return {
  "monaqa/dial.nvim",
  keys = {
    {
      "<leader><C-a>",
      mode = { "v" },
      function() return require("dial.map").inc_visual() end,
      expr = true,
      desc = "Increment",
    },
    {
      "<leader><C-x>",
      mode = { "v" },
      function() return require("dial.map").dec_visual() end,
      expr = true,
      desc = "Decrement",
    },
    {
      "g<leader><C-a>",
      mode = { "v" },
      function() return require("dial.map").inc_gvisual() end,
      expr = true,
      desc = "Increment",
    },
    {
      "g<leader><C-x>",
      mode = { "v" },
      function() return require("dial.map").dec_gvisual() end,
      expr = true,
      desc = "Decrement",
    },
    {
      "<leader><C-a>",
      function() return require("dial.map").inc_normal() end,
      expr = true,
      desc = "Increment",
    },
    {
      "<leader><C-x>",
      function() return require("dial.map").dec_normal() end,
      expr = true,
      desc = "Decrement",
    },
  },
  config = function()
    local augend = require "dial.augend"
    require("dial.config").augends:register_group {
      default = {
        augend.integer.alias.decimal,
        augend.integer.alias.hex,
        augend.date.alias["%Y/%m/%d"],
        augend.constant.alias.bool,
        augend.semver.alias.semver,
        augend.case.new {
          types = { "camelCase", "PascalCase", "snake_case", "SCREAMING_SNAKE_CASE" },
        },
      },
    }
  end,
}
