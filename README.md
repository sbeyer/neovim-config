I have been using vim for a long time but never got to clean up and modernize my messy vim configuration.
When I switched to neovim, I decided to configure it from scratch.
This is work in progress.

# Installation

## neovim

```sh
# download nvim v0.6.0 (or replace v0.6.0 by stable or latest)
wget https://github.com/neovim/neovim/releases/download/v0.6.0/nvim.appimage

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
 * `bat` (very optional)
 * Note that LSP servers will be installed nvim-local on demand

## this configuration

Move away old stuff because it could interfere with the new configuration.
```sh
test -d ~/.local/share/nvim && mv ~/.local/share/nvim ~/.local/share/nvim.bak-"$(date -I)"
test -d ~/.config/nvim && mv ~/.config/nvim ~/.config/nvim.bak-"$(date -I)"
```

Then do
```sh
cd ~/.config/
git clone https://github.com/sbeyer/neovim-config.git nvim
```
and you are set.
