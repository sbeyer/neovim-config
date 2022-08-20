local config = {
  polish = function()
    ----- File-type specific configuration

    -- Recognize qml
    vim.filetype.add {
      extension = {
        qml = "qmljs",
      }
    }

    -- I never deal with plain tex, always LaTeX... respect that!
    vim.cmd('autocmd FileType plaintex set ft=tex')

    -- disable displaying math (etc) for TeX and LaTeX
    vim.cmd('autocmd FileType tex set conceallevel=0')
  end
}

return config
