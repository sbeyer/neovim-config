return {
  n = {
    ["<leader>gS"] = {
      function()
        require("gitsigns").stage_buffer()
      end,
      desc = "Stage git buffer"
    },

    ["<leader>gR"] = {
      "<cmd>!git rm -f %<cr>",
      desc = "git rm current file"
    },
  }
}