# Features/Changes on top of AstroNvim

[Back to README](README.md)

## Project and language support

- **Repository-local VS Code snippets.** LuaSnip loads `.vscode/*.code-snippets`
  from the edited file's Git repository.
  Snippets stay isolated to that repository and follow the current buffer filetype.
  File associations in `.vscode/settings.json` select filetypes automatically.
  Also repository-local `xml.fileAssociations` for XSD-backed validation, completion,
  and hover documentation is used by the XML LSP server.

- **Clangd compilation database discovery.** Finds `compile_commands.json` in
  the project root and its `build*/` directories, deduplicating symlinks.
  Uses a single database automatically, asks when several exist, and remembers
  the choice per project for the session. Missing databases trigger a notification
  without disabling clangd's normal fallback (`lua/clangd/compile-commands.lua`).

- **Pinned clangd version.** Mason installs my configured clangd version.
  First use each session installs it if needed
  before starting clangd; installation failures warn and fall back to an available
  executable (`lua/clangd/version.lua`, `lua/plugins/mason.lua`).

- **QML language support.** Uses the system-installed `qmlls` for QML files
  (`lua/plugins/astrolsp.lua`).

## Git and diffs

- **Git commit layout.** When neovim starts with a Git commit or merge message,
  the editing pane shows only the supplied message, without Git's generated
  status footer. Read-only status appears below it, with staged changes beside
  it in wide terminals or below the status in narrow ones. Normal `:wq` and
  `:cq` behavior is preserved
  (`lua/plugins/git.lua`, `lua/git/commit.lua`).

- **Git file removal.** `<Space>gD` offers deletion or untracking with buffer
  and Git change warnings, then searches for filename references. Deletion also
  closes the file's buffer (`lua/plugins/git.lua`, `lua/git/remove.lua`).

- **Diffview.** Repository-wide diffs, staged-change review, file history, and
  conflict resolution through AstroCommunity. `<Space>D` groups its actions
  while preserving AstroNvim's buffer shortcuts; inside Diffview, `<Space>e`
  toggles its file panel instead of the normal explorer
  (`lua/community.lua`, `lua/plugins/diffview.lua`).

- **Diff outlines.** Jump between changed files and their `@@` hunks through
  the symbol picker or outline in `diff` and `git` buffers. Breadcrumbs show
  the current file and hunk; renamed and binary files also appear (Aerial,
  `lua/plugins/aerial.lua` and `queries/diff/aerial.scm`).

## Editing and navigation

- **Smart increment/decrement.** `<Space>` + `Ctrl-a` / `Ctrl-x` toggle booleans,
  cycle identifier cases, and change numbers, dates, and versions (dial.nvim).

- **Calculator completion.** Arithmetic expressions offer their results as
  completion suggestions (cmp-calc through AstroCommunity).

- **Subword motions.** `_w`, `_b`, `_e` behave like the usual word motions
  but they stop at subword boundaries as they exist for `snake_case`, `camelCase`
  `PascalCase`, etc.

- **Surround editing.** `gza`, `gzd`, and `gzr` add, delete, and replace quotes,
  brackets, and other surrounding pairs, including around Visual selections
  (mini.surround through AstroCommunity).

- **Flash navigation.** Label-based jumps and enhanced character finds are
  enabled through AstroCommunity (`lua/community.lua`).

- **Tab navigation.** `<Space>ft` picks an open tab through Snacks; `g<Tab>`
  returns to the most recently visited tab, skipping closed tabs.

- **Selective format-on-save.** Automatic formatting on save is enabled only
  for Rust; other filetypes can still be formatted manually when supported
  (`lua/plugins/astrolsp.lua`).

## Interface and editor behavior

- **Hybrid diagnostics.** Inline messages appear everywhere except the cursor
  line, where virtual lines show the diagnostics below the code instead.
  `<Space>uv` cycles through hybrid, virtual lines only, inline text only, and
  neither, without hiding signs or underlines. Refreshes after edits and buffer
  switches keep the cursor-line filtering correct (`lua/plugins/astrocore.lua`).

- **Large-file folding protection.** Large buffers use manual folding rather
  than constructing expensive automatic fold trees, keeping generated files
  responsive when opening them or switching windows. Manual folds remain available
  (`lua/plugins/astrocore.lua`, `lua/plugins/astroui.lua`).

- **Custom statusline and window headers.** Compact three-letter mode labels
  and tab numbers appear in the statusline. The separate tabline/bufferline and
  its dependent shortcuts are disabled. The active window shows symbol
  breadcrumbs when available; other windows show their file paths. Headers also
  show modified/read-only state and filetype labels where useful
  (`lua/plugins/heirline.lua`, `lua/plugins/astroui.lua`).

- **Consistent annotation backgrounds.** Inline diagnostics, diagnostic virtual
  lines, inlay hints, and CodeLens use matching subtle backgrounds while retaining
  their foreground colors and text styles. Backgrounds adapt to colorscheme changes
  (`lua/plugins/astroui.lua`).

- **Dynamic, darker gutter.** Separate Git and diagnostic sign columns and a
  fold column appear only when needed, alongside relative line numbers.
  `<Space>u<` switches between dynamic and fixed column widths
  (`lua/plugins/heirline.lua`, `lua/plugins/astroui.lua`, `lua/plugins/astrocore.lua`).

- **Mouse input limited to Normal and Visual modes.** Mouse input is disabled
  in Insert mode to avoid accidental cursor movement while typing
  (`lua/plugins/astrocore.lua`).
