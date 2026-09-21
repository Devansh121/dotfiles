return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")

    -- Project Files: fuzzy-find every file
    vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
    -- Ctrl-p: only git-tracked files (fast in big repos; errors if not a git repo)
    vim.keymap.set("n", "<C-p>", builtin.git_files, {})
    -- Project Search: grep across the project for a term you type
    vim.keymap.set("n", "<leader>ps", function()
      builtin.grep_string({ search = vim.fn.input("Grep > ") })
    end)
    -- Grep the word under the cursor
    vim.keymap.set("n", "<leader>pws", function()
      builtin.grep_string({ search = vim.fn.expand("<cword>") })
    end)
    -- Search Neovim help
    vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})
  end,
}
