-- Claude Code chat inside Neovim, as a centered floating terminal you can
-- toggle on/off (like a Telescope window). The session keeps running while
-- hidden. Also wires the IDE protocol so Claude sees your file/selection and
-- proposes edits as diffs you accept/deny in Neovim.
-- Docs: https://github.com/coder/claudecode.nvim
local toggle_key = "<M-c>" -- Alt+c: works in normal, visual and inside the terminal
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "ClaudeCode", "ClaudeCodeFocus", "ClaudeCodeSelectModel", "ClaudeCodeAdd",
      "ClaudeCodeSend", "ClaudeCodeTreeAdd", "ClaudeCodeStatus", "ClaudeCodeStart",
      "ClaudeCodeStop", "ClaudeCodeOpen", "ClaudeCodeClose", "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny", "ClaudeCodeCloseAllDiffs",
    },
    keys = {
      { toggle_key, "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: toggle float", mode = { "n", "x" } },
      { "<leader>cc", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: toggle float" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: resume session" },
      { "<leader>cC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continue last" },
      { "<leader>cm", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: select model" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: add current buffer" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: send selection" },
      { "<leader>cs", "<cmd>ClaudeCodeTreeAdd<cr>", desc = "Claude: add file from netrw", ft = { "netrw" } },
      { "<leader>ca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: accept diff" },
      { "<leader>cd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: deny diff" },
    },
    opts = {
      terminal = {
        ---@module "snacks"
        ---@type snacks.win.Config|{}
        snacks_win_opts = {
          position = "float",
          width = 0.9,
          height = 0.9,
          border = "rounded",
          keys = {
            claude_hide = {
              toggle_key,
              function(self) self:hide() end,
              mode = "t",
              desc = "Hide",
            },
          },
        },
      },
    },
  },
}
