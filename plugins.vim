lua packs = {}
for file in split(globpath(stdpath('config') . '/enabled/', '*.lua'), '\n')
  lua table.insert(packs, dofile(vim.g.file))
endfor

lua << EOF
paq_list = {}
for _, plugin_config in pairs(packs) do
  for _, plugin in pairs(plugin_config.plugins) do
    table.insert(paq_list, plugin)
  end
end

require("paq")(paq_list)

for _, plugin_config in pairs(packs) do
  plugin_config.config()
end
EOF

function! s:update_features()
  PaqSync
  TSUpdate
endfunction

command! UpdateFeatures call <SID>update_features()
