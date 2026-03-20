require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "]c", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next git hunk" })
map("n", "[c", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous git hunk" })
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview git hunk" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
