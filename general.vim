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

" workaround nvim crash (older versions)
imap <F2> <ESC><F2>

" disable weird completion behavior
set suffixes=
