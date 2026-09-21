return {
  "mbbill/undotree",
  config = function()
    -- <leader>u : open the undo history tree (branches and all)
    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
  end,
}
