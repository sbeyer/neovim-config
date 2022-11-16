-- modify variables used by heirline but not defined in the setup call directly
return {
  -- define the separators between each section
  separators = {
    left = { "", " " }, -- separator for the left side of the statusline
    right = { " ", " " }, -- separator for the right side of the statusline
  },
  -- add new colors that can be used by heirline
  colors = {
    blank_bg = "#5c6370",
    file_bg = "#3e4452",
  },
}
