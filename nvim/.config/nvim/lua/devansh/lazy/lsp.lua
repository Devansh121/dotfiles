return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Mason: installs language servers for you (replaces the old lsp-zero setup)
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
    -- Autocomplete engine + sources
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    -- Tell servers what completion features the client supports
    local capabilities = vim.tbl_deep_extend(
      "force",
      {},
      vim.lsp.protocol.make_client_capabilities(),
      require("cmp_nvim_lsp").default_capabilities()
    )

    -- Neovim 0.11+ native LSP config API.
    -- Apply capabilities to every server:
    vim.lsp.config("*", { capabilities = capabilities })

    -- Per-server tweaks:
    --  lua_ls  -> stop it complaining about the global `vim`
    vim.lsp.config("lua_ls", {
      settings = { Lua = { diagnostics = { globals = { "vim" } } } },
    })
    --  clangd (C/C++) and pyright (Python) work well with defaults.
    vim.lsp.config("clangd", {})
    vim.lsp.config("pyright", {})

    require("mason").setup()
    require("mason-lspconfig").setup({
      -- These get auto-installed on first launch and auto-enabled.
      ensure_installed = { "lua_ls", "pyright", "clangd" },
      automatic_enable = true,
    })

    -- ---- Autocomplete (nvim-cmp) ----
    local cmp = require("cmp")
    local cmp_select = { behavior = cmp.SelectBehavior.Select }
    cmp.setup({
      snippet = {
        expand = function(args) require("luasnip").lsp_expand(args.body) end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-p>"] = cmp.mapping.select_prev_item(cmp_select), -- previous suggestion
        ["<C-n>"] = cmp.mapping.select_next_item(cmp_select), -- next suggestion
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),   -- accept
        ["<C-Space>"] = cmp.mapping.complete(),               -- trigger completion
      }),
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
      }, {
        { name = "buffer" },
        { name = "path" },
      }),
    })

    -- Diagnostics: show inline messages
    vim.diagnostic.config({ virtual_text = true })

    -- ---- Buffer-local LSP keymaps (only active when a server is attached) ----
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(e)
        local opts = { buffer = e.buf }
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)            -- go to definition
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)                  -- hover docs
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts) -- show error under cursor
        vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
        vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
        vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)  -- code actions / quick fixes
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)   -- find references
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)       -- rename symbol
        vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)     -- signature help (insert mode)
      end,
    })
  end,
}
