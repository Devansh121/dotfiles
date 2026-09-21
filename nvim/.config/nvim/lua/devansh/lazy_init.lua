-- Bootstrap lazy.nvim (the modern replacement for Packer)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load every plugin spec in lua/devansh/lazy/
require("lazy").setup({
  { import = "devansh.lazy" },
}, {
  change_detection = { notify = false },
})
