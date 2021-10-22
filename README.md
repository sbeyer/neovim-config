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
```

## recommended tools

Install nice-to-haves using `apt` or `pacman`:
 * `fzf`
 * `ripgrep`
 * clang (`clang-format` and `clangd`)
 * `bat` (very optional)

## package manager

Install [paq-nvim](https://github.com/savq/paq-nvim)

```sh
git clone --depth=1 https://github.com/savq/paq-nvim.git \
    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/start/paq-nvim
```

## this configuration

Do
```sh
cd ~/.config/
test -d nvim && mv nvim nvim~
git clone https://github.com/sbeyer/neovim-config.git nvim
nvim +PaqSync +qa
```
and you are set.
