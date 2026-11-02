---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = {
      mappings = {
        n = {
          ["<Leader>D"] = { desc = "Diffview" },
          ["<Leader>D<CR>"] = { "<Cmd>DiffviewOpen<CR>", desc = "Open changed files" },
          ["<Leader>Ds"] = { "<Cmd>DiffviewOpen --cached<CR>", desc = "Review staged changes" },
          ["<Leader>Dh"] = { "<Cmd>DiffviewFileHistory %<CR>", desc = "Current file history" },
          ["<Leader>DH"] = { "<Cmd>DiffviewFileHistory<CR>", desc = "Repository history" },
        },
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
    },
    opts = function(_, opts)
      local actions = require "diffview.actions"
      local shared = {
        { "n", "<leader>e", actions.toggle_files, { desc = "Toggle Diffview file panel" } },
        { "n", "<leader>b", false },
        { "n", "<leader>q", "<Cmd>DiffviewClose<CR>", { desc = "Close Diffview" } },
        { "n", "<leader>Df", actions.focus_files, { desc = "Focus Diffview file panel" } },
        { "n", "<leader>Dl", actions.cycle_layout, { desc = "Cycle diff layout" } },
      }
      opts.keymaps = opts.keymaps or {}
      for _, context in ipairs { "view", "file_panel", "file_history_panel" } do
        opts.keymaps[context] = vim.list_extend(opts.keymaps[context] or {}, vim.deepcopy(shared))
      end

      for key, target in pairs { o = "ours", t = "theirs", b = "base", a = "all" } do
        -- Move upstream <Leader>c mappings away from AstroNvim's close-buffer key.
        for _, context in ipairs { "view", "file_panel" } do
          vim.list_extend(opts.keymaps[context], {
            { "n", "<leader>c" .. key, false },
            { "n", "<leader>c" .. key:upper(), false },
            {
              "n",
              "<leader>D" .. key:upper(),
              actions.conflict_choose_all(target),
              { desc = "Choose " .. target .. " for all conflicts in file" },
            },
          })
        end
        table.insert(opts.keymaps.view, {
          "n",
          "<leader>D" .. key,
          actions.conflict_choose(target),
          { desc = "Choose " .. target .. " for conflict" },
        })
      end
      table.insert(opts.keymaps.view, {
        "n",
        "<leader>D0",
        actions.conflict_choose "none",
        { desc = "Delete conflict region" },
      })
    end,
  },
}
