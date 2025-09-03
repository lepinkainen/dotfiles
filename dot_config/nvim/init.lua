require("config.lazy")

-- Relative numbers for lines
vim.opt.relativenumber = true
-- Show absolute line on active
vim.opt.number = true

-- These create custom shortcuts using leader
vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>", { desc = "Toggle file tree" })
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>", { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>", { desc = "Search in files" })
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })

