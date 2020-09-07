" make whitespace visible
set list
set listchars=tab:^`,trail:~,extends:\\,precedes:»

" make line numbers visible
set number

" make implicit linebreaks visible
set showbreak=\ \ «
set breakindent
set breakindentopt=shift:2,sbr

" completion behavior in command mode
set wildmode=longest:full,full

"""""""""""""""""""""""""""""""""""""""""""""""""""""""
" plugins using https://github.com/junegunn/vim-plug
call plug#begin(stdpath('data') . '/plugged')

" git support
Plug 'tpope/vim-fugitive'

" nice statusline
Plug 'vim-airline/vim-airline'

" language client for LSPs
Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': 'bash install.sh',
  \ }

" Multi-entry selection UI.
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" install fzf and ripgrep on your system! And maybe bat (for syntax highlighting in previews)

" Auto-completion
Plug 'Shougo/deoplete.nvim', {
  \ 'do': ':UpdateRemotePlugins'
  \ }

" Path navigator
Plug 'justinmk/vim-dirvish'
" ..with git support
Plug 'kristijanhusak/vim-dirvish-git'

call plug#end()

" LanguageClient-neovim configuration
let g:LanguageClient_serverCommands = {
  \ 'c': ['clangd-10', '-background-index'],
  \ 'cpp': ['clangd-10', '-background-index'],
  \ }
nmap <F5> <Plug>(lcn-menu)
nmap <silent>K <Plug>(lcn-hover)
nmap <silent> gd <Plug>(lcn-definition)
nmap <silent> <F2> <Plug>(lcn-rename)

" configuration for deoplete (auto-completion)
let g:deoplete#enable_at_startup = 1

" get :Files quick
nnoremap <F1> :Files<Cr>

function! RipgrepFzf(query, fullscreen)
  let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepFzf(<q-args>, <bang>0)
