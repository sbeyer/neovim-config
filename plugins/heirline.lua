return function(config)
  -- adapt statusline, AstroNvim's default is ordered weirdly and lacks mode information
  local status = config[1]

  -- add mode text
  status[1] = astronvim.status.component.mode { mode_text = { padding = { left = 1, right = 1 } } }

  -- remove file info
  table.remove(status, 3)

  -- move diagnostics (index 5) before lsp info (index 9)
  local diag = status[4]
  table.remove(status, 4)
  table.insert(status, 7, diag)

  -- adapt winbar: filename please!
  local winbar = config[2]

  winbar[1] = {
    condition = astronvim.status.condition.is_active,
    astronvim.status.component.file_info {
      padding = { right = 1 },
      unique_path = {},
      file_modified = {},
      file_read_only = {},
      -- update = "BufEnter" -- seems not to be necessary
    },
    astronvim.status.component.breadcrumbs { hl = astronvim.status.hl.get_attributes("winbar", true) },
  }

  return config
end
