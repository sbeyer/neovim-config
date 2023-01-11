return {
  setup = function()
    vim.g.material_style = 'darker'
  end,

  config = function()
    require('material').setup {
      high_visibility = {
        darker = true
      }
    }
  end
}
