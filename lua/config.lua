-- Personal feature settings. Restart neovim after changing startup defaults.
return {
  -- Require the same major/minor release, with at least this patch version.
  supported_nvim_version = "0.12.6",

  -- Mason installs this exact clangd version. First use each session checks it;
  -- failed installations warn and use an available executable for that session.
  clangd_version = "20.1.8",

  -- Path to the system-installed QML language server, not managed by Mason.
  -- Set to "" to disable QML LSP attachment.
  -- A missing or non-executable nonempty path warns when opening a QML file.
  --
  -- For projects using qt_add_qml_module(), run from the existing build directory:
  --
  --   cmake -DQT_QML_GENERATE_QMLLS_INI=ON .
  --   cmake --build .
  --
  -- This generates .qmlls.ini in each QML module's source directory;
  -- qmlls reads these settings automatically. Custom module roots must be supplied
  -- through qt_add_qml_module(IMPORT_PATH ...). Regenerate after changing builds
  -- or import paths, then restart the language server. Keep generated files out of Git.
  -- Neovim does not configure or build. Qmlls's automatic CMake rebuilds are disabled.
  qmlls_path = "/opt/qt6.8/bin/qmlls",

  -- Default gutter widths: true shrinks unused sign/fold columns; false keeps them fixed.
  -- <Space>u< toggles the current session without changing this default.
  dynamic_gutter = true,

  -- Default diagnostics: "hybrid" shows inline text except on the cursor line,
  -- where virtual lines appear below the code. "virtual_text" and "virtual_lines"
  -- show only that style on all diagnostic lines. <Space>uv cycles styles (and off)
  -- for the current session without changing this default.
  diagnostic_display = "hybrid",
}
