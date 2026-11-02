---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    treesitter = { ensure_installed = { "gitcommit", "gitattributes", "git_rebase" } },
    autocmds = {
      git_commit_layout = {
        {
          event = "VimEnter",
          once = true,
          desc = "Show staged changes alongside Git's commit message",
          callback = function()
            if vim.fn.argc() ~= 1 then return end
            local buf = vim.api.nvim_get_current_buf()
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(buf) then require("git.commit").open(buf) end
            end)
          end,
        },
      },
    },
    mappings = {
      n = {
        ["<Leader>gD"] = {
          function() require("git.remove").current() end,
          desc = "Remove current file from Git",
        },
      },
    },
  },
}
