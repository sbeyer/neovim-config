---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = {
      -- Snacks picker input highlighting uses the regex parser.
      treesitter = { ensure_installed = { "regex" } },
    },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      opts.dashboard.sections = {
        { section = "keys", gap = 1, padding = 3 },
        { section = "startup" },
      }
      for _, item in ipairs(opts.dashboard.preset.keys) do
        if item.key == "'" then item.icon = " " end
        if item.key == "s" then item.icon = " " end
      end
      table.insert(opts.dashboard.preset.keys, 1, {
        key = "h",
        icon = " ",
        desc = "Usage Guide  ",
        action = function()
          vim.cmd.edit(vim.fn.stdpath "config" .. "/USAGE.md")
          vim.schedule(function() require("aerial").snacks_picker() end)
        end,
      })
      table.insert(opts.dashboard.preset.keys, {
        key = "g",
        icon = " ",
        desc = "Git Changes  ",
        action = "<Leader>gt",
        enabled = function()
          if vim.fn.executable "git" ~= 1 then return false end
          local result = vim.system({ "git", "status", "--porcelain" }, { text = true }):wait()
          return result.code == 0 and result.stdout ~= ""
        end,
      })
      table.insert(opts.dashboard.preset.keys, { key = "q", icon = " ", desc = "Quit  ", action = ":qa" })
    end,
  },
}
