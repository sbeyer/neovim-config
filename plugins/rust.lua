return {
  require('user.utils').ensure_treesitter_parsers({ "rust", "toml" }),
  require('user.utils').ensure_lsps({ "rust_analyzer", "taplo" }),

  -- Rust goodies
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    opts = function()
      return {
        server = require("astronvim.utils.lsp").config "rust_analyzer"
      }
    end,
    dependencies = {
      {
        "jay-babu/mason-nvim-dap.nvim",
        opts = function(_, opts)
          if not opts.ensure_installed then
            opts.ensure_installed = {}
          end

          table.insert(opts.ensure_installed, "codelldb")
        end,
      },
    },
  },

  -- Crates magic for Cargo.toml
  {
    "Saecki/crates.nvim",
    event = { "BufRead Cargo.toml" },
    opts = {
      null_ls = {
        enabled = true,
        name = "crates.nvim",
      },
    },
    init = function()
      vim.api.nvim_create_autocmd("BufRead", {
        group = vim.api.nvim_create_augroup("CmpSourceCargo", { clear = true }),
        pattern = "Cargo.toml",
        callback = function()
          require("cmp").setup.buffer { sources = { { name = "crates" } } }
          require "crates"
        end,
      })
    end,
  },
}
