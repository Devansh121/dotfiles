-- 99: ThePrimeagen's AI client for Neovim.
-- Shells out to the `claude` CLI (Claude Code) — no API key needed, it reuses
-- your existing `claude` login. Docs: https://github.com/ThePrimeagen/99
return {
  {
    "ThePrimeagen/99",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      local _99 = require("99")
      local basename = vim.fs.basename(vim.uv.cwd())

      _99.setup({
        provider = _99.Providers.ClaudeCodeProvider,
        -- Uncomment to override the provider default (claude-sonnet-4-5):
        -- model = "claude-opus-5",

        logger = {
          level = _99.INFO,
          path = "/tmp/" .. basename .. ".99.debug",
          print_on_error = true,
        },

        -- Must stay inside the project cwd, otherwise Claude Code's permission
        -- model blocks writes to it and generation fails.
        tmp_dir = "./tmp",

        completion = {
          source = "cmp", -- you use nvim-cmp; enables #rules / @files completion in the prompt
          files = {},
        },

        -- Auto-attached context files, searched from the current file up to cwd.
        md_files = { "AGENTS.md", "CLAUDE.md" },
      })

      -- Visual mode: replace the selection with what Claude generates
      vim.keymap.set("v", "<leader>9v", function() _99.visual() end,
        { desc = "99: replace selection" })

      -- Search the project; results land in the quickfix list (<C-k>/<C-j>)
      vim.keymap.set("n", "<leader>9s", function() _99.search() end,
        { desc = "99: search project" })

      -- Free-form agent run (edits files), reopen last result, cancel
      vim.keymap.set("n", "<leader>9i", function() _99.vibe() end,
        { desc = "99: vibe (agent run)" })
      vim.keymap.set("n", "<leader>9o", function() _99.open() end,
        { desc = "99: open last result" })
      vim.keymap.set("n", "<leader>9x", function() _99.stop_all_requests() end,
        { desc = "99: cancel requests" })
      vim.keymap.set("n", "<leader>9l", function() _99.view_logs() end,
        { desc = "99: view logs" })

      -- Work items: set a task, then search for what's left to do
      local worker = _99.Extensions.Worker
      vim.keymap.set("n", "<leader>9w", function() worker.set_work() end,
        { desc = "99: set work item" })
      vim.keymap.set("n", "<leader>9W", function() worker.search() end,
        { desc = "99: what's left for work item" })

      -- Telescope pickers to switch model / provider on the fly
      vim.keymap.set("n", "<leader>9m", function()
        require("99.extensions.telescope").select_model()
      end, { desc = "99: pick model" })
      vim.keymap.set("n", "<leader>9p", function()
        require("99.extensions.telescope").select_provider()
      end, { desc = "99: pick provider" })
    end,
  },
}
