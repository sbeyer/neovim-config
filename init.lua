local config = {
  colorscheme = "material",

  polish = function()
    ----- File-type specific configuration

    -- I never deal with plain tex, always LaTeX... respect that!
    vim.cmd('autocmd FileType plaintex set ft=tex')

    -- disable displaying math (etc) for TeX and LaTeX
    vim.cmd('autocmd FileType tex set conceallevel=0')
  end
}

return config
