return {
  "tpope/vim-fugitive",
  config = function()
    -- <leader>gs : git status (stage/unstage/commit from here)
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
  end,
}
