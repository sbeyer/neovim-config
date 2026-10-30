-- Personal feature settings. Restart neovim after changing startup defaults.
return {
  -- Require the same major/minor release, with at least this patch version.
  supported_nvim_version = "0.12.6",

  -- Mason installs this clangd version; the first use each session checks it.
  clangd_version = "21.1.8",

  -- Shrink unused sign and fold columns; false keeps their widths fixed. Change with <Space>u<
  dynamic_gutter = true,

  -- "hybrid", "virtual_text", or "virtual_lines". Change with <Space>uv
  diagnostic_display = "hybrid",
}
