return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    lazy = false,
    priority = 1000, -- load the colorscheme before other plugins
    config = function()
      require("rose-pine").setup({
        styles = { italic = false },
      })

      -- "Color my pencils": set colorscheme + transparent background.
      -- Global so you can re-run it any time with :lua ColorMyPencils()
      function ColorMyPencils(color)
        color = color or "rose-pine"
        vim.cmd.colorscheme(color)
        vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
        vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
      end

      ColorMyPencils()
    end,
  },
}
