-- Editor options (the "sets" from the transcript)

vim.opt.guicursor = ""            -- fat block cursor in every mode

vim.opt.nu = true                 -- line numbers
vim.opt.relativenumber = true     -- relative numbers (jump with 9k / 5j etc.)

-- 4-space indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false              -- no line wrapping

-- No swap/backup files; use a persistent undo history instead (see undotree)
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false          -- don't keep matches highlighted
vim.opt.incsearch = true          -- but do highlight incrementally while typing

vim.opt.termguicolors = true      -- 24-bit color

vim.opt.scrolloff = 8             -- keep 8 lines visible above/below cursor
vim.opt.signcolumn = "yes"        -- always show the sign column (avoids text shifting)
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50           -- faster response for diagnostics/CursorHold

vim.opt.colorcolumn = "80"        -- ruler at column 80

-- Give leader chords more time before keys fall back to their plain meaning
vim.opt.timeoutlen = 2000
