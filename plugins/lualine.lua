local ll_diff = {
  "diff",
  symbols = { added = " ", modified = "柳", removed = " " },
}

local l_git = { 'branch', ll_diff }

local ll_diag = {
  "diagnostics",
  sources = { "nvim_diagnostic" },
  symbols = { error = " ", warn = " ", info = " ", hint = " " },
}

local l_fileinfo = {
  'filesize',
  'encoding',
  'fileformat',
}

local l_code = {
  'filetype',
  ll_diag,
}

local l_location = {
  {
    'location',
    padding = { left = 0, right = 0 },
    separator = { left = '', right = nil },
  },
  {
    require("core.status").progress_bar,
    padding = { left = 0, right = 0 },
    separator = { left = nil, right = nil },
    color = { fg = '#000000' }
  },
}

return {
  -- Default lualine configuration as of 2022-03-28
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { "NvimTree", "neo-tree", "dashboard", "Outline" },
    always_divide_middle = false,
    globalstatus = false,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { { 'filename', path = 1 } },
    lualine_c = l_git,
    lualine_x = l_fileinfo,
    lualine_y = l_code,
    lualine_z = l_location,
  },
  inactive_sections = {
    lualine_a = { { 'filename', path = 2, color = 'StatusLineTerm' } },
    lualine_b = {},
    lualine_c = l_git,
    lualine_x = l_fileinfo,
    lualine_y = l_code,
    lualine_z = l_location,
  },
  tabline = {},
  extensions = {}
}
