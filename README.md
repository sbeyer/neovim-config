I have been using vim for a long time but never got to clean up and modernize my messy vim configuration.
When I switched to neovim, I decided to configure it from scratch.
This is work in progress.

# Installation

## neovim

```sh
# download nvim v0.5.1 (or replace v0.5.1 by stable or latest)
wget https://github.com/neovim/neovim/releases/download/v0.5.1/nvim.appimage

# make executable
chmod +x nvim.appimage

# move executable to a location in your $PATH
mv nvim.appimage ~/.local/bin/nvim

# also override vim
ln -s ~/.local/bin/nvim ~/.local/bin/vim
```

## requirements

 * `git`
 * `tar`
 * `curl`
 * C/C++ compiler with standard library

## recommended tools

Install nice-to-haves using `apt` or `pacman`:
 * `fzf` (note: will also be installed by plugin at first use)
 * `ripgrep`
 * LSP servers: `clangd`, `rls`, `pyright`
 * `bat` (very optional)

## package manager

Install [paq-nvim](https://github.com/savq/paq-nvim)

```sh
git clone --depth=1 https://github.com/savq/paq-nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim
```

## this configuration

Move away old stuff
```sh
test -d ~/.local/share/nvim && mv ~/.local/share/nvim ~/.local/share/nvim.bak-"$(date -I)"
test -d ~/.config/nvim && mv ~/.config/nvim ~/.config/nvim.bak-"$(date -I)"
```

Then do
```sh
cd ~/.config/
git clone https://github.com/sbeyer/neovim-config.git nvim
nvim +UpdateFeatures +qa
```
and you are set.
