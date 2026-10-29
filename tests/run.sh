#!/bin/sh
# Run all Plenary test specs in isolated, headless Neovim processes.
set -eu

CDPATH= cd -- "$(dirname -- "$0")/.."

exec nvim --headless -u NONE -i NONE \
  -c 'lua vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/plenary.nvim"); require("plenary.test_harness").test_directory("tests", { minimal_init = "NONE", sequential = true })' \
  -c 'cquit'
