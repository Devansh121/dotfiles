return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master", -- classic, stable API (the newer `main` branch is a rewrite)
  lazy = false,
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "vimdoc", "lua", "python", "c", "cpp",
        "bash", "javascript", "typescript",
      },
      sync_install = false,
      auto_install = true, -- grab a parser automatically when you open a new filetype
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
