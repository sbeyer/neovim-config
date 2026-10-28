-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      diagnostics = { virtual_text = true, virtual_lines = false }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    -- passed to `vim.filetype.add`
    filetypes = {
      -- see `:h vim.filetype.add` for usage
      extension = {
        foo = "fooscript",
        -- recognize qml
        qml = "qmljs",
        -- always ft=tex (LaTeX), never ft=plaintex (TeX)
        tex = "tex",
        -- html support is much better than XML, so this is a workaround
        xml = "html",
        xsd = "html",
        schema = "html",
      },
      filename = {
        [".foorc"] = "fooscript",
        Jenkinsfile = "groovy",
      },
      pattern = {
        [".*/etc/foo/.*"] = "fooscript",
      },
    },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        -- Allow Git and diagnostic signs to appear side by side.
        signcolumn = "yes:2",
        -- keep statusline when in command mode
        cmdheight = 1,
        -- completion behavior in command mode
        wildmode = "longest:full,full",
        -- never show tabline (we show tab information in statusline)
        showtabline = 0,
        -- disable weird completion behavior regarding suffixes
        suffixes = "",
        -- enable mouse only for Normal and Visual mode only
        mouse = "nv",
        -- make whitespace visible
        list = true,
        listchars = "tab:^`,trail:~,extends:\\,precedes:»",
        -- make implicit linebreaks visible
        wrap = true, -- sets vim.opt.wrap
        linebreak = false,
        showbreak = "  «",
        breakindent = true,
        breakindentopt = "shift:2,sbr",
        -- scrolloffs
        scrolloff = 5,
        sidescrolloff = 8,
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    autocmds = {
      user_formatoptions = {
        {
          event = "FileType",
          desc = "Continue comments on Enter, but not with o or O",
          callback = function()
            vim.opt_local.formatoptions:append "r"
            vim.opt_local.formatoptions:append "/"
            vim.opt_local.formatoptions:remove "o"
          end,
        },
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- Keep the v6 <Leader>q mapping: the old replacement requires vim-sayonara.
        ["<Leader>Q"] = { "<Cmd>qa<CR>", desc = "Quit all" },
        ["<Leader>gR"] = {
          function() vim.cmd("!git rm -f -- " .. vim.fn.shellescape(vim.fn.expand "%", true)) end,
          desc = "git rm current file",
        },

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,
      },
    },
  },
}
