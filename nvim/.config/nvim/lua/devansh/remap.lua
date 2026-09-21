-- Leader must be set BEFORE plugins load
vim.g.mapleader = " "
-- Space alone does nothing, so a slow <leader> chord never moves the cursor
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Back to the netrw file explorer
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Move highlighted lines up/down (re-indents automatically)
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join line below but keep cursor in place
vim.keymap.set("n", "J", "mzJ`z")

-- Half-page jumps keep the cursor centered
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search terms stay centered
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste over a selection WITHOUT clobbering your yank register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Yank to the system clipboard (leader y) vs. vim-only (plain y)
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete into the void register (doesn't touch your yank)
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Ctrl-c behaves like Esc (matters in visual-block edits)
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Q is a trap. Disable it.
vim.keymap.set("n", "Q", "<nop>")

-- Quickfix / location list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Replace the word under the cursor across the whole file
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- chmod +x the current file
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
