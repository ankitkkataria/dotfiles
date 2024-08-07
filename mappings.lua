require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("i", "jj", "<ESC>")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "K", "5k")
vim.keymap.set("n", "J", "5j")
vim.keymap.set("v", "J", "5j")
vim.keymap.set("v", "K", "5k")
vim.keymap.set("x", "p", [["_dP]])

vim.keymap.set({"n", "v"}, "y", [["+y]])
vim.keymap.set("n", "Y", [["+Y]])

vim.keymap.set({"n", "v"}, "p", [["+p]])
vim.keymap.set("n", "P", [["+P]])

vim.keymap.set({"n", "v"}, "d", [["+d]])


-- EasyMotion Settings
local hop = require('hop')
vim.keymap.set('', 'f', function()
  hop.hint_char1()
end, {remap=true})
vim.keymap.set('', '<leader>l', function()
  hop.hint_lines_skip_whitespace()
end, {remap=true})
