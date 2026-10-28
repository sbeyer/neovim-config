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

The former AstroNvim v3.45.3 configuration is kept in `old-v3/` as a migration reference;
it is not loaded. Migration is ongoing, and the old plugin customizations have not all
been ported.

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

Mason installs tools in Neovim's data directory, but some packages need additional
system runtimes or package managers: Node.js with `npm`, Python with `pip` and `venv`
support, or Rust with `cargo`. You can later run `:checkhealth mason` to check the
available tools.

### Step 2: get Neovim

On Linux x86-64, the simplest way is to download an AppImage into a directory on
your `PATH`. AppImages require FUSE; see the [Neovim installation guide][nvim] for
extraction instructions if FUSE is unavailable.


```sh
mkdir -p ~/.local/bin
curl -fL --output ~/.local/bin/nvim https://github.com/neovim/neovim/releases/download/v0.12.6/nvim-linux-x86_64.appimage
chmod +x ~/.local/bin/nvim
```

You can of course use another version of Neovim, probably the latest one, but I
provide the version that I use and that I know my configuration works with.

Optionally, also use Neovim when running `vim`, provided `~/.local/bin/vim` does not
already exist:

```sh
ln -s ~/.local/bin/nvim ~/.local/bin/vim
```

### Step 3: back up an existing configuration

The following paths assume Linux with the default XDG locations. Adjust them if you use
custom locations. Close Neovim first and move any existing configuration out of the way:

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

### Step 5: usage and maintenance

The leader key is **Space** and the local leader is **`,`**. Press Space and pause to
see available mappings.

Type `:Mason` or `<Leader>pm` to manage language servers, formatters, and other tools.
Run `:Lazy` or `<Leader>ps` to inspect installed plugins.

Use `:Lazy check` (`<Leader>pu`) to check for plugin updates, and `:Lazy update`
(`<Leader>pU`) to update plugins, including AstroNvim. `:AstroUpdate` (`<Leader>pa`)
updates both plugins and Mason packages. `:TSUpdate` updates Treesitter parsers.

Run `:AstroVersion` to see the installed AstroNvim version and `:checkhealth` to
diagnose problems.

AstroNvim is constrained to major version 6 in `lua/lazy_setup.lua`. `lazy-lock.json`
records plugin revisions. Follow AstroNvim's update notifications; updating its pinned
plugins can require running the update a second time. Restart Neovim after configuration
or plugin changes.

## Configuration layout

| File / directory            | Purpose                                             |
| --------------------------- | --------------------------------------------------- |
| `init.lua`                  | Bootstrap lazy.nvim and load the configuration      |
| `lua/lazy_setup.lua`        | AstroNvim version, leader keys, and plugin imports  |
| `lua/plugins/astrocore.lua` | Vim options, filetypes, mappings, and autocommands  |
| `lua/plugins/astrolsp.lua`  | LSP configuration and references picker             |
| `lua/plugins/heirline.lua`  | Statusline, winbar, tabline, and statuscolumn       |
| `lua/plugins/`              | Additional lazy.nvim plugin specifications          |
| `lua/community.lua`         | Optional AstroCommunity imports; currently disabled |
| `lua/polish.lua`            | Optional final setup; currently disabled            |
| `old-v3/`                   | Legacy configuration, with ported sections marked   |

For further customization, see the [AstroNvim documentation][astro].

[astro]: https://docs.astronvim.com/
[kitty]: https://sw.kovidgoyal.net/kitty/
[kitty-fonts]: https://sw.kovidgoyal.net/kitty/faq/#kitty-is-not-able-to-use-my-favorite-font
[nerd-fonts]: https://www.nerdfonts.com/font-downloads
[hack]: https://github.com/ryanoasis/nerd-fonts/releases/download/v3.5.1/Hack.zip
[getnf]: https://github.com/ronniedroid/getnf
[nvim]: https://github.com/neovim/neovim/blob/master/INSTALL.md
