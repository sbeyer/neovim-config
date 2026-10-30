-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

local function large_buffer_folding(args)
  if require("astrocore.buffer").is_large(args.buf) then
    for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
      if vim.wo[win].foldmethod ~= "manual" then vim.wo[win].foldmethod = "manual" end
    end
  end
end

local diagnostic_text_options, diagnostic_line_options = {}, {}
local function cycle_diagnostic_display()
  local config = assert(vim.diagnostic.config())
  if type(config.virtual_text) == "table" then diagnostic_text_options = vim.deepcopy(config.virtual_text) end
  if type(config.virtual_lines) == "table" then diagnostic_line_options = vim.deepcopy(config.virtual_lines) end

  local text, lines, mode
  if config.virtual_text and config.virtual_lines then
    text, lines, mode = false, true, "virtual lines"
  elseif config.virtual_lines then
    text, lines, mode = true, false, "virtual text"
  elseif config.virtual_text then
    text, lines, mode = false, false, "off"
  else
    text, lines, mode = true, true, "hybrid"
  end

  diagnostic_text_options.current_line = nil
  diagnostic_line_options.current_line = text and lines
  if text and lines then diagnostic_text_options.current_line = false end
  vim.diagnostic.config {
    virtual_text = text and diagnostic_text_options or false,
    virtual_lines = lines and diagnostic_line_options or false,
  }
  require("astrocore").notify("Diagnostic display: " .. mode)
end

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
      diagnostics = { virtual_text = true, virtual_lines = true }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = { current_line = false },
      virtual_lines = { current_line = true },
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
        -- The statuscolumn expands sign slots only when needed.
        signcolumn = "auto:2",
        foldcolumn = "auto:1",
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
        dynamic_statuscolumn = true,
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    autocmds = {
      nvim_version_check = {
        {
          event = "VimEnter",
          once = true,
          desc = "Warn when running an unsupported Neovim version",
          callback = function()
            local supported = vim.g.supported_nvim_version
            local major, minor, patch = supported:match "^(%d+)%.(%d+)%.(%d+)$"
            local current = vim.version()
            if
              current.major ~= tonumber(major)
              or current.minor ~= tonumber(minor)
              or current.patch < tonumber(patch)
            then
              vim.schedule(function()
                local message = ("Configuration expected Neovim version %s (same major/minor); running %s (%s)."):format(
                  supported,
                  tostring(current),
                  vim.v.progpath
                )
                vim.notify(message, vim.log.levels.WARN, { title = "Unsupported Neovim version" })
              end)
            end
          end,
        },
      },
      hybrid_diagnostics = {
        {
          event = { "TextChanged", "InsertLeave", "BufEnter" },
          desc = "Refresh cursor-aware diagnostics after edits and buffer switches",
          callback = function(args)
            -- BufEnter runs before Neovim restores the window's cursor position.
            vim.schedule(function()
              if args.buf ~= vim.api.nvim_get_current_buf() then return end
              local config = assert(vim.diagnostic.config())
              if
                type(config.virtual_text) == "table"
                and config.virtual_text.current_line == false
                and type(config.virtual_lines) == "table"
                and config.virtual_lines.current_line == true
              then
                -- Native extmark restoration can revive inline text hidden by current_line.
                vim.diagnostic.show(nil, args.buf)
              end
            end)
          end,
        },
      },
      large_buffer_folding = {
        {
          event = "User",
          pattern = "AstroLargeBuf",
          desc = "Use manual folding for large buffers",
          callback = large_buffer_folding,
        },
        {
          event = "BufWinEnter",
          desc = "Keep large-buffer folding manual in newly opened windows",
          callback = large_buffer_folding,
        },
      },
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
        ["<Leader>u<"] = {
          function()
            vim.g.dynamic_statuscolumn = vim.g.dynamic_statuscolumn == false
            vim.cmd "redraw!"
          end,
          desc = "Toggle dynamic statuscolumn width",
        },
        ["<Leader>uv"] = { cycle_diagnostic_display, desc = "Cycle diagnostic display" },
        ["<Leader>uV"] = false,
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
