return {
  n = {
    ["<leader>q"] = false, -- overwritten in plugins/buffers.lua
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
