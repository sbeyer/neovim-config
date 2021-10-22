call plug#begin(stdpath('data') . '/plugged')

let g:clang_version_suffix = '-10'

for file in split(globpath(stdpath('config') . '/plugin/', '*.vim'), '\n')
  exec 'source' file
endfor

call plug#end()

for file in split(globpath(stdpath('config') . '/plugin/', '*.lua'), '\n')
  exec 'luafile' file
endfor
