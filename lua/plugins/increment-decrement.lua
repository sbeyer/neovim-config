---@type LazySpec
return {
  "monaqa/dial.nvim",
  keys = {
    {
      "<leader><C-a>",
      mode = { "v" },
      function() require("dial.map").manipulate("increment", "visual") end,
      desc = "Increment",
    },
    {
      "<leader><C-x>",
      mode = { "v" },
      function() require("dial.map").manipulate("decrement", "visual") end,
      desc = "Decrement",
    },
    {
      "g<leader><C-a>",
      mode = { "v" },
      function() require("dial.map").manipulate("increment", "gvisual") end,
      desc = "Increment",
    },
    {
      "g<leader><C-x>",
      mode = { "v" },
      function() require("dial.map").manipulate("decrement", "gvisual") end,
      desc = "Decrement",
    },
    {
      "<leader><C-a>",
      function() require("dial.map").manipulate("increment", "normal") end,
      desc = "Increment",
    },
    {
      "<leader><C-x>",
      function() require("dial.map").manipulate("decrement", "normal") end,
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
          types = { "snake_case", "camelCase", "PascalCase", "SCREAMING_SNAKE_CASE" },
        },
      },
    }
  end,
}
