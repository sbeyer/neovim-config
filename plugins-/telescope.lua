local fb_actions = require("telescope").extensions.file_browser.actions

return {
  extensions = {
    file_browser = {
      path = "%:p:h", -- run from directory of current buffer
      mappings = {
        i = {
          ["<C-z>"] = fb_actions.toggle_hidden,
        },
        n = {
          z = fb_actions.toggle_hidden,
        },
      },
    },
  },
}
