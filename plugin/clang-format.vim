" for :ClangFormat
Plug 'rhysd/vim-clang-format'

let g:clang_format#command = "clang-format"
if executable(g:clang_format#command . g:clang_version_suffix)
  let g:clang_format#command .= g:clang_version_suffix
endif

let g:clang_format#detect_style_file = 1
let g:clang_format#enable_fallback_style = 0

nmap <silent> <F2> :%ClangFormat<CR>
