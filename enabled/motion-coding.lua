return {
  -- <leader>w/<leader>b jumps but aware of camelCase and snake_case
  'bkad/CamelCaseMotion',

  config = function()
    vim.g.camelcasemotion_key = '<leader>'
  end
}
