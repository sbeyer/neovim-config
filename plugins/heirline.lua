return function(config)
  -- the first element of the configuration table is the statusline
  config[1] = {
    -- default highlight for the entire statusline
    hl = { fg = "fg", bg = "bg" },
    -- each element following is a component in astronvim.status module

    -- add the vim mode component
    astronvim.status.component.mode {
      -- enable mode text with padding as well as an icon before it
      mode_text = { padding = { right = 1, left = 1 } },
      -- define the highlight color for the text
      hl = { fg = "bg" },
      -- surround the component with a separators
      surround = {
        -- it's a left element, so use the left separator
        separator = "left",
        -- set the color of the surrounding based on the current mode using astronvim.status module
        color = function() return { main = astronvim.status.hl.mode_bg(), right = "blank_bg" } end,
      },
    },
    -- we want an empty space here so we can use the component builder to make a new section with just an empty string
    astronvim.status.component.builder {
      { provider = "" },
      -- define the surrounding separator and colors to be used inside of the component
      -- and the color to the right of the separated out section
      surround = { separator = "left", color = { main = "blank_bg", right = "file_bg" } },
    },
    -- add a section for the currently opened file information
    astronvim.status.component.file_info {
      -- enable the file_icon and disable the highlighting based on filetype
      file_icon = { highlight = false, padding = { left = 0 } },
      -- add padding
      padding = { right = 1 },
      -- define the section separator
      surround = { separator = "left" },
    },
    -- add a component for the current git branch if it exists and use no separator for the sections
    astronvim.status.component.git_branch { surround = { separator = "none" } },
    -- add a component for the current git diff if it exists and use no separator for the sections
    astronvim.status.component.git_diff { padding = { left = 1 }, surround = { separator = "none" } },
    -- fill the rest of the statusline
    -- the elements after this will appear in the middle of the statusline
    astronvim.status.component.fill(),
    -- add a component to display if the LSP is loading, disable showing running client names, and use no separator
    astronvim.status.component.lsp { lsp_client_names = false, surround = { separator = "none", color = "bg" } },
    -- fill the rest of the statusline
    -- the elements after this will appear on the right of the statusline
    astronvim.status.component.fill(),
    -- add a component for the current diagnostics if it exists and use the right separator for the section
    astronvim.status.component.diagnostics { surround = { separator = "right" } },
    -- add a component to display LSP clients, disable showing LSP progress, and use the right separator
    astronvim.status.component.lsp { lsp_progress = false, surround = { separator = "right" } },
    -- navigation section
    astronvim.status.component.nav {},
  }

  -- a second element in the heirline setup would override the winbar
  -- by only providing a single element we will only override the statusline
  -- and use the default winbar in AstroNvim

  -- return the final confiuration table
  return config
end
