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

Only unported user plugin customizations from my former AstroNvim v3.45.3
configuration remain directly in `old-v3/`, for possible later migration. The old
distribution and settings covered by the active configuration have been removed.
These reference snippets are not loaded and may require updates before reuse.

## Features and usage

See the [features overview](FEATURES.md) for additions and customizations beyond
AstroNvim's defaults.

The [usage guide](USAGE.md) is a general write-up on how to use the whole thing,
i.e. an attempted reference for how to use the resulting configuration.

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

### Step 5: configure features

My feature settings and their documentation live in `lua/config.lua`.
Restart neovim after changing startup defaults; UI shortcuts only change the
current session.

## Tests

The configuration includes automated tests. Run them from the repository root:

```sh
tests/run.sh
```

If tests fail, check the settings in `lua/config.lua`.

[astro]: https://docs.astronvim.com/
[kitty]: https://sw.kovidgoyal.net/kitty/
[kitty-fonts]: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
[nerd-fonts]: https://www.nerdfonts.com/font-downloads
[hack]: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.zip
[getnf]: https://github.com/ronniedroid/getnf
[nvim]: https://github.com/neovim/neovim/blob/master/INSTALL.md
