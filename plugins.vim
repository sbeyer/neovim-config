call plug#begin(stdpath('data') . '/plugged')

let g:clang_version_suffix = '-10'
let g:config_plugin_file_list = [
  \ 'fugitive',
  \ 'statusline',
  \ 'fzf',
  \ 'LanguageClient',
  \ 'autocompletion',
  \ 'navigator',
  \ 'indentation',
  \ 'clang-format',
  \ 'snippets',
  \ ]

for file in g:config_plugin_file_list
  exec 'source' stdpath('config') . '/plugin/'. file . '.vim'
endfor

call plug#end()
