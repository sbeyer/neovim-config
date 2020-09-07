I have been using vim for a long time but never got to clean up and modernize my messy vim configuration.
When I switched to neovim, I decided to configure it from scratch.
This is work in progress.

# Installation

Install using `apt` or `pacman`:
 * `neovim`
 * `fzf`
 * `ripgrep`
 * clang (`clang-format` and `clangd`)
 * `bat` (very optional)

Then install [vim-plug](https://github.com/junegunn/vim-plug)

Then do
```sh
cd ~/.config/nvim/
git clone https://github.com/sbeyer/neovim-config.git
nvim +PlugInstall +UpdateRemotePlugins +qa
```
and you are set.
