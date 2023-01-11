I have been using vim for a long time but never got to clean up and modernize my messy vim configuration.
When I switched to neovim, I decided to configure it from scratch.
And I failed terribly, at least, at my perfectionism.

So I decided to depend on the work and perfectionism of others and use a pre-configured neovim distribution.
**Kudos goes to [AstroNvim](https://github.com/AstroNvim/AstroNvim)**.
My flavor is added with this repository.

# Installation

I did not write a fancy shell script, so you have to do all these steps manually.
This is actually good, so you can review them and ask yourself if it is right to do so.

## Step 1: requirements

Make sure these things are installed on your system:

 * `git`
 * `tar`
 * `curl`
 * C/C++ compiler with standard library

Yes, it's all pretty basic.

## Step 2: recommended tools

For the best experience, make sure [the stuff mentioned here](https://astronvim.github.io/#-requirements)
is installed.

As [Nerd Font](https://www.nerdfonts.com/font-downloads), I am fond of the
[Hack Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/Hack.zip).
You might also want to check [getnf](https://github.com/ronniedroid/getnf).

LSP servers will be installed nvim-local on demand, however, some LSP servers need
additional tools like `node` to be able to install them.

## Step 3: get neovim

```sh
# download nvim v0.8.0 (or replace the version by stable or latest)
wget https://github.com/neovim/neovim/releases/download/v0.8.0/nvim.appimage

# make executable
chmod +x nvim.appimage

# move executable to a location in your $PATH
mv nvim.appimage ~/.local/bin/nvim

# also override vim
ln -s ~/.local/bin/nvim ~/.local/bin/vim
```

## Step 4: cleanup (skip if not necessary)

Move away old stuff because it could interfere with the new configuration.
```sh
test -d ~/.local/share/nvim && mv ~/.local/share/nvim ~/.local/share/nvim.bak-"$(date -I)"
test -d ~/.config/nvim && mv ~/.config/nvim ~/.config/nvim.bak-"$(date -I)"
test -d ~/.cache/nvim && mv ~/.cache/nvim ~/.cache/nvim.bak-"$(date -I)"
```

## Step 5: get the configs

Do
```sh
git clone --branch v1.10.0 https://github.com/AstroNvim/AstroNvim.git ~/.config/nvim
git clone https://github.com/sbeyer/neovim-config.git ~/.config/nvim/lua/user
nvim +PackerSync
```
and you are set.

## Step 6: afterwards

When editing code and some other files with specific syntax, type
```
:LspInstall
```
to select and install a corresponding LSP server.

LSP servers for Rust and C/C++ will be installed automatically.

Type
```
:LspInstallInfo
```
to get an overview of installed servers and interactively install/uninstall/upgrade
LSP servers.

Note that treesitter parsers are installed automatically when necessary.
You can type
```
:TSInstallInfo
```
to get an overview, and
```
:TSUpdate
```
upgrades all the installed parsers.

To upgrade AstroVim, type
```
:AstroUpdate
```
and to upgrade plugins, type
```
:PackerSync
```
