""" General configuration

" make whitespace visible
set list
set listchars=tab:^`,trail:~,extends:\\,precedes:»

" make line numbers visible: current line absolute, other lines relative
set number relativenumber

" make implicit linebreaks visible
set showbreak=\ \ «
set breakindent
set breakindentopt=shift:2,sbr

" completion behavior in command mode
set wildmode=longest:full,full

" find: ignore case when all letters are lower-case
set smartcase
set ignorecase

" disable weird completion behavior
set suffixes=

" define , as our leader key
let mapleader = ','


""" File-type specific configuration

" I never deal with plain tex, always LaTeX... respect that!
autocmd FileType plaintex set ft=tex

" disable displaying math (etc) for TeX and LaTeX
autocmd FileType tex set conceallevel=0


""" Now do the plugin magic!

lua require('plugins')
