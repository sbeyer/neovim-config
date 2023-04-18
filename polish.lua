return function()
  vim.api.nvim_create_autocmd({ "FileType" }, {
    callback = function()
      vim.opt.formatoptions:append("r")
      vim.opt.formatoptions:append("/")
      vim.opt.formatoptions:remove("o")
    end,
  })

  -- File-type specific configuration
  vim.filetype.add({
    extension = {
      qml = "qmljs", -- recognize qml
      tex = "tex",   -- always ft=tex (LaTeX), never ft=plaintex (TeX)
    },
  })
end
