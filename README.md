# sbeyer's neovim configuration

## Preface

I have been using vim since basically forever but never got to clean up and modernize my
messy vim configuration. When I switched to neovim, I decided to configure it from
scratch. And I failed terribly, at least, at my perfectionism.

So I decided to depend on the work and perfectionism of others and use a pre-configured
neovim distribution. **Kudos goes to
[AstroNvim](https://github.com/AstroNvim/AstroNvim)**. My flavor is added with this
repository.

The active configuration uses **AstroNvim v6.1.1**, managed as a plugin by
[lazy.nvim](https://lazy.folke.io/). I have been using AstroNvim v3.45.3 for
a long time because I do not enjoy updating my neovim configuration; never touch a
running system! However, with more modern stuff coming to neovim and via plugins, there
is a need to update. So my new configuration is made with heavy use of LLMs because I
still do not enjoy configuring neovim or writing lua.

The unported parts of my former AstroNvim v3.45.3 configuration are kept in `old-v3/`
as a reference, e.g., to later port them if I still think it is useful. The contents
of this directory are not loaded.

## Installation

I did not write a fancy shell script, so you have to do all these steps manually. This
is actually good, so you can review them and ask yourself if it is right to do so.

### Step 1: requirements and recommended tools

See the [current AstroNvim requirements][astro] for details.

For the best experience, install `rg` (ripgrep) for live grep and a clipboard provider
such as `xclip` on X11 or `wl-copy`/`wl-paste` on Wayland.
Treesitter also needs the Tree-sitter CLI, which AstroNvim can install through Mason
if it is not installed on the system.

Use a terminal with true-color support, such as [Kitty][kitty]. Kitty includes a
built-in Nerd Font for symbols, so you do not need a patched text font there; see its
[font FAQ][kitty-fonts]. For other terminals, configure a current
[Nerd Font][nerd-fonts]. I am fond of [Hack Nerd Font v3.5.1][hack].
You might also want to check [getnf][getnf].

Mason installs tools in neovim's data directory, but some packages need additional
system runtimes or package managers: Node.js with `npm`, Python with `pip` and `venv`
support, or Rust with `cargo`. You can later run `:checkhealth mason` to check the
available tools.

### Step 2: get neovim

On Linux x86-64, the simplest way is to download an AppImage into a directory on
your `PATH`. AppImages require FUSE; see the [neovim installation guide][nvim] for
extraction instructions if FUSE is unavailable.


```sh
mkdir -p ~/.local/bin
curl -fL --output ~/.local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.appimage
chmod +x ~/.local/bin/nvim
```

You can of course use another version of neovim, probably the latest one, but I
provide the version that I use and that I know my configuration works with.
My configuration prints a warning on startup if you are using another version
because not everything is guaranteed to work as expected.

Optionally, also use neovim when running `vim`, provided `~/.local/bin/vim` does not
already exist:

```sh
ln -s ~/.local/bin/nvim ~/.local/bin/vim
```

### Step 3: back up an existing configuration

The following paths assume Linux with the default XDG locations. Adjust them if you use
custom locations. Close neovim first and move any existing configuration out of the way:

```sh
backup_dir="nvim.bak-$(date +%Y%m%d-%H%M%S)"
test -d ~/.config/nvim && mv ~/.config/nvim ~/.config/$backup_dir
test -d ~/.local/share/nvim && mv ~/.local/share/nvim ~/.local/share/$backup_dir
test -d ~/.local/state/nvim && mv ~/.local/state/nvim ~/.local/state/$backup_dir
test -d ~/.cache/nvim && mv ~/.cache/nvim ~/.cache/$backup_dir
```

The data, state, and cache backups are optional but useful when switching from a
different configuration. These directories will be recreated; retain the backups if you
need their installed tools or other contents later.

### Step 4: clone this configuration

```sh
git clone https://github.com/sbeyer/neovim-config.git ~/.config/nvim
nvim
```

Allow the initial downloads and installations to finish.

## Features on top of AstroNvim

The main additions and customizations beyond AstroNvim's defaults are:

- **Clangd compilation database discovery.** Finds `compile_commands.json` in
  the project root and its `build*/` directories, deduplicating symlinks.
  Uses a single database automatically, asks when several exist, and remembers
  the choice per project for the session. Missing databases trigger a notification
  without disabling clangd's normal fallback (`lua/clangd/compile-commands.lua`).

- **Pinned clangd version.** `clangd_version` in `lua/config.lua` selects the
  clangd version installed by Mason. First use each session installs it if needed
  before starting clangd; installation failures warn and fall back to an available
  executable (`lua/clangd/version.lua`, `lua/plugins/mason.lua`).

- **Diff outlines.** Diff file headers appear as symbols with their `@@` hunks
  nested underneath, including patches without `index` metadata and files with
  only rename or binary changes. Available through the symbol picker and outline,
  with jump targets and breadcrumb ranges (Aerial, `lua/plugins/aerial.lua` and
  `queries/diff/aerial.scm`).

- **Git file removal.** `<Space>gD` offers deletion or untracking with buffer
  and Git change warnings, then searches for filename references. Deletion also
  closes the file's buffer (`lua/plugins/git.lua`, `lua/git/remove.lua`).

- **Custom statusline and window headers.** Compact three-letter mode labels
  and tab numbers replace the separate tabline. The active window shows symbol
  breadcrumbs when available; other windows show their file paths. Headers also
  show modified/read-only state and filetype labels where useful
  (`lua/plugins/heirline.lua`, `lua/plugins/astroui.lua`).

- **Dynamic, darker gutter.** Separate Git and diagnostic sign columns and a
  fold column appear only when needed, alongside relative line numbers.
  `<Space>u<` switches between dynamic and fixed column widths
  (`lua/plugins/heirline.lua`, `lua/plugins/astroui.lua`, `lua/plugins/astrocore.lua`).

- **Hybrid diagnostics.** Inline messages appear everywhere except the cursor
  line, where virtual lines show the diagnostics below the code instead.
  `<Space>uv` cycles through hybrid, virtual lines only, inline text only, and
  neither, without hiding signs or underlines. Refreshes after edits and buffer
  switches keep the cursor-line filtering correct (`lua/plugins/astrocore.lua`).

- **Consistent annotation backgrounds.** Inline diagnostics, diagnostic virtual
  lines, inlay hints, and CodeLens use matching subtle backgrounds while retaining
  their foreground colors and text styles. Backgrounds adapt to colorscheme changes
  (`lua/plugins/astroui.lua`).

- **Large-file folding protection.** Large buffers use manual folding rather
  than constructing expensive automatic fold trees, keeping generated files
  responsive when opening them or switching windows. Manual folds remain available
  (`lua/plugins/astrocore.lua`, `lua/plugins/astroui.lua`).

- **Flash navigation.** Label-based jumps and enhanced character finds are
  enabled through AstroCommunity (`lua/community.lua`).

- **Selective format-on-save.** Automatic formatting on save is enabled only
  for Rust; other filetypes can still be formatted manually when supported
  (`lua/plugins/astrolsp.lua`).

My feature settings live in `lua/config.lua`: the supported neovim version,
the clangd version, `dynamic_gutter` (`true` or `false`), and `diagnostic_display`
(`"hybrid"`, `"virtual_text"`, or `"virtual_lines"`). Restart neovim after changing
these defaults; UI shortcuts only change the current session.

## Usage

See the [usage guide](USAGE.md) for editing, navigation, language tools, Git,
and maintenance.

[astro]: https://docs.astronvim.com/
[kitty]: https://sw.kovidgoyal.net/kitty/
[kitty-fonts]: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
[nerd-fonts]: https://www.nerdfonts.com/font-downloads
[hack]: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.zip
[getnf]: https://github.com/ronniedroid/getnf
[nvim]: https://github.com/neovim/neovim/blob/master/INSTALL.md
