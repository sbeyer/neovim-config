---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          -- Unlike <Nop>, a callback prevents WhichKey from taking over the prefix.
          ["_"] = { function() end, desc = "Subword motion prefix" },
          ["__"] = { "_", desc = "First nonblank character (linewise)" },
        },
        x = {
          ["_"] = { function() end, desc = "Subword motion prefix" },
          ["__"] = { "_", desc = "First nonblank character (linewise)" },
        },
        o = {
          -- Cancel a pending operator if the prefix times out.
          ["_"] = { "<Esc>", desc = "Cancel incomplete subword motion" },
          ["__"] = { "_", desc = "First nonblank character (linewise)" },
        },
      },
    },
  },
  {
    "chrisgrieser/nvim-spider",
    opts = {},
    keys = {
      {
        "_w",
        "<Cmd>lua require('spider').motion('w')<CR>",
        mode = { "n", "x", "o" },
        desc = "Next subword",
      },
      {
        "_b",
        "<Cmd>lua require('spider').motion('b')<CR>",
        mode = { "n", "x", "o" },
        desc = "Previous subword",
      },
      {
        "_e",
        "<Cmd>lua require('spider').motion('e')<CR>",
        mode = { "n", "x", "o" },
        desc = "End of subword",
      },
    },
  },
}
