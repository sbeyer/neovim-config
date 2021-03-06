" language client for LSPs
Plug 'autozimu/LanguageClient-neovim', {
  \ 'branch': 'next',
  \ 'do': 'bash install.sh',
  \ }

let g:clangd_path = 'clangd'
if executable(g:clangd_path . g:clang_version_suffix)
  let g:clangd_path .= g:clang_version_suffix
endif
let g:LanguageClient_serverCommands = {
  \ 'c': [g:clangd_path, '-background-index'],
  \ 'cpp': [g:clangd_path, '-background-index'],
  \ 'rust': ['rls'],
  \ }

function LanguageClient_maps()
  if has_key(g:LanguageClient_serverCommands, &filetype)
    nmap <F5> <Plug>(lcn-menu)
    nmap <silent><F2> <Plug>(lcn-format)
    nmap <silent>K <Plug>(lcn-hover)
    nmap <silent>gD <Plug>(lcn-definition)
    nmap <silent>gd :split<CR>gD
  endif
endfunction

autocmd FileType * call LanguageClient_maps()
