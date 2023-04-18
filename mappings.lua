return {
  n = {
    ["<leader>q"] = { -- TODO: remove from here and keep it in plugins/buffers.lua
      "<cmd>Sayonara<cr>",
      desc = "Close window / quit",
    },
    ["<leader>Q"] = {
      "<cmd>qa<cr>",
      desc = "Quit all",
    },
    ["<leader>gR"] = {
      "<cmd>!git rm -f %<cr>",
      desc = "git rm current file",
    },
  },
}
