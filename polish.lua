return function()
  ----- File-type specific configuration

  vim.filetype.add {
    extension = {
      qml = "qmljs", -- recognize qml
      tex = "tex", -- always ft=tex (LaTeX), never ft=plaintex (TeX)
    }
  }
end
