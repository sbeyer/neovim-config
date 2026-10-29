#!/bin/sh
# Run all Plenary test specs in isolated, headless Neovim processes.
set -eu

CDPATH= cd -- "$(dirname -- "$0")/.."

exec nvim --headless -u NONE -i NONE -l tests/run.lua
