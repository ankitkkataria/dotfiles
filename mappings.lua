require "nvchad.mappings"

-- Basic remaps
vim.keymap.set("i", "jj", "<ESC>")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "K", "5k")
vim.keymap.set("n", "J", "5j")
vim.keymap.set("v", "J", "5j")
vim.keymap.set("v", "K", "5k")
vim.keymap.set("x", "p", [["_dP]])
vim.keymap.set("n", "<leader>/",":noh<cr>")
vim.api.nvim_set_keymap('n', 'gh', '<cmd>lua vim.lsp.buf.hover()<CR>', { noremap = true, silent = true })
vim.keymap.set({"n", "v"}, "mb", "%")

-- Copy/cut and paste to system clipboard
vim.keymap.set({"n", "v"}, "y", [["+y]])
vim.keymap.set({"n", "v"}, "Y", [["+Y]])
vim.keymap.set({"n", "v"}, "p", [["+p]])
vim.keymap.set({"n", "v"}, "P", [["+P]])
vim.keymap.set({"n", "v"}, "d", [["+d]])

-- EasyMotion Settings
local hop = require('hop')
vim.keymap.set('', 'f', function()
  hop.hint_char1()
end, {remap=true})
vim.keymap.set('', '<leader>l', function()
  hop.hint_lines_skip_whitespace()
end, {remap=true})

-- -- Visual mode key mapping
-- vim.keymap.set('v', '<C-d>', '<Plug>(VM-Find-Under)', { noremap = true, silent = true })
--
-- -- Normal mode key mapping
-- vim.keymap.set('n', '<C-d>', '<Plug>(VM-Find-Under)', { noremap = true, silent = true })

-- Select text with Shift + Arrow keys in Insert mode
vim.api.nvim_set_keymap('i', '<S-Left>', '<C-O>v<Left>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<S-Right>', '<C-O>v<Right>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<S-Up>', '<C-O>v<Up>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<S-Down>', '<C-O>v<Down>', { noremap = true, silent = true })

-- Select text to the beginning and end of the line with Shift + Home/End in Insert mode
vim.api.nvim_set_keymap('i', '<S-Home>', '<C-O>v<Home>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('i', '<S-End>', '<C-O>v<End>', { noremap = true, silent = true })

-- Delete selected text with Backspace in Visual mode and go to Insert mode
vim.api.nvim_set_keymap('v', '<BS>', 'dgi', { noremap = true, silent = true })

-- Indenting selected text and even after that we shall stay in visual mode so we can further indent
vim.api.nvim_set_keymap('v', '<', '<gv', { noremap = true, silent = true })
vim.api.nvim_set_keymap('v', '>', '>gv', { noremap = true, silent = true })

-- Indent using Tab in visual mode
vim.api.nvim_set_keymap('v', '<Tab>', '>gv', { noremap = true, silent = true })

-- Outdent using Shift-Tab in visual mode
vim.api.nvim_set_keymap('v', '<S-Tab>', '<gv', { noremap = true, silent = true })

-- Quickly switch between current and previous opened tab
vim.api.nvim_set_keymap('n', '<leader><leader>', '<C-^>', { noremap = true, silent = true })

-- Splits
vim.api.nvim_set_keymap('n', '<leader>sv', ':vsplit<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sh', ':split<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>sc', ':close<CR>', { noremap = true, silent = true })
