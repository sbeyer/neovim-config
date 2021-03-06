" Multi-entry selection UI.
" :Files, <F1>, :Rg, :RG etc
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
" install fzf and ripgrep on your system! And maybe bat (for syntax highlighting in previews)

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
command! Rw call RipgrepFzf(expand('<cword>'), 0)
