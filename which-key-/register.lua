return {
  n = {
    ["<leader>"] = {
      a = {
        name = "Annotate",
        ["<cr>"] = { function() require("neogen").generate() end, "Current" },
        c = { function() require("neogen").generate { type = "class" } end, "Class" },
        f = { function() require("neogen").generate { type = "func" } end, "Function" },
        t = { function() require("neogen").generate { type = "type" } end, "Type" },
        F = { function() require("neogen").generate { type = "file" } end, "File" },
      },

      f = {
        name = "Find",
        e = { "<cmd>Telescope file_browser<cr>", "File explorer" },
        M = { "<cmd>Telescope man_pages<cr>", "Search man pages" },
        k = { "<cmd>Telescope keymaps<cr>", "Search vim keymaps" },
        n = { "<cmd>Telescope notify<cr>", "Search vim notifications" },
        r = { "<cmd>Telescope registers<cr>", "Search vim registers" },
        C = { "<cmd>Telescope colorscheme<cr>", "Search vim colorschemes" },
      },
    }
  },
}
