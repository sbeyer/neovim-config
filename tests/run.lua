vim.opt.rtp:append(vim.fn.stdpath "data" .. "/lazy/plenary.nvim")

require("plenary.test_harness").test_directory("tests", {
  minimal_init = "NONE",
  sequential = true,
})
