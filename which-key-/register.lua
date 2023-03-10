return {
  n = {
    ["<leader>"] = {

      f = {
        name = "Find",
        M = { "<cmd>Telescope man_pages<cr>", "Search man pages" },
        k = { "<cmd>Telescope keymaps<cr>", "Search vim keymaps" },
        n = { "<cmd>Telescope notify<cr>", "Search vim notifications" },
        r = { "<cmd>Telescope registers<cr>", "Search vim registers" },
        C = { "<cmd>Telescope colorscheme<cr>", "Search vim colorschemes" },
      },
    }
  },
}
