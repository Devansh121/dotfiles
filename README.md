# dotfiles

Stow-style layout: each top-level folder is a package whose contents mirror `$HOME`.

| package  | what                                                   |
|----------|--------------------------------------------------------|
| nvim     | Neovim (lazy.nvim, telescope, harpoon, native LSP + mason, 99, claudecode) |
| tmux     | prefix `C-Space`, tmux-resurrect with event-driven autosave |
| bash     | `.bashrc` (nvm, bun, cargo, zig, claude profile helpers, tmux autosave hook) |
| bin      | `dev-gh` (gh with personal account), `tmux-rs-*` resurrect helpers |
| i3       | i3 config, caps as ctrl, ghostty + rofi bindings         |
| polybar / rofi / picom / dunst | i3 rice, Tokyo Night              |
| ghostty  | Tokyo Night, JetBrainsMono Nerd Font                   |
| starship | Tokyo Night prompt                                     |
| lazygit  | config                                                 |

## Install

```sh
git clone https://github.com/Devansh121/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh            # everything
./install.sh nvim tmux  # a subset
```

`install.sh` needs no dependencies. With GNU stow installed, `stow nvim tmux ...` from this directory does the same thing.

## Runtime deps
nvim >= 0.11, tmux, tpm (`git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`), ghostty, starship, fzf, ripgrep, JetBrainsMono Nerd Font.
