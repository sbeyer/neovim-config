let g:config_file_list = [
  \ 'general',
  \ 'plugins'
  \ ]

for file in g:config_file_list
  exec 'source' stdpath('config') . '/'. file . '.vim'
endfor
