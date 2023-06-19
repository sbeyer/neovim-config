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
      -- recognize qml
      qml = "qmljs",

      -- always ft=tex (LaTeX), never ft=plaintex (TeX)
      tex = "tex",

      -- html support is much better than XML, so this is a workaround
      xml = "html",
      xsd = "html",
      schema = "html",
    },
    filename = {
      Jenkinsfile = "groovy",
    }
  })
end
