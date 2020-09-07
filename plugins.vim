" plugins using https://github.com/junegunn/vim-plug
call plug#begin(stdpath('data') . '/plugged')

let g:config_plugin_file_list = [
  \ 'fugitive',
  \ 'statusline',
  \ 'fzf',
  \ 'LanguageClient',
  \ 'autocompletion',
  \ 'navigator',
  \ ]

for file in g:config_plugin_file_list
  exec 'source' stdpath('config') . '/plugin/'. file . '.vim'
endfor

call plug#end()
