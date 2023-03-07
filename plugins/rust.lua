return {
  -- Ensure rust-related treesitter parsers are installed
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      elseif opts.ensure_installed == "all" then
        return
      end

      table.insert(opts.ensure_installed, { "rust", "toml" })
    end,
  },

  -- Ensure LSPs for Rust and TOML are installed
  {
    "williamboman/mason-lspconfig.nvim",
    opts = function(_, opts)
      if not opts.ensure_installed then
        opts.ensure_installed = {}
      end

      vim.list_extend(opts.ensure_installed, { "rust_analyzer", "taplo" })
    end,
  },

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
