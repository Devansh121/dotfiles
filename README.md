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
| herdr    | prefix `C-Space`, `C-S-Left/Right` switch workspaces   |
| terminator | resize_left/right unbound so herdr gets `C-S-Left/Right` |

## Install

Fresh machine (Ubuntu 22.04+): installs the tools, then links the configs.

```sh
git clone https://github.com/Devansh121/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap.sh            # tools + configs + herdr Claude hook
./bootstrap.sh --no-rice  # skip i3 / polybar / rofi / picom / dunst
./bootstrap.sh --dry-run  # show what it would do
```

Configs only (tools already installed):

```sh
./install.sh            # everything
./install.sh nvim tmux  # a subset
```

`install.sh` needs no dependencies. With GNU stow installed, `stow nvim tmux ...` from this directory does the same thing.

## What bootstrap installs
Skips anything already installed.

- apt: git, curl, unzip, tmux, terminator, fzf, ripgrep (+ i3, polybar, rofi, picom, dunst unless `--no-rice`)
- nvim (latest release tarball, apt's is too old), lazygit, starship, herdr → `~/.local/bin`
- ghostty (snap), tpm, JetBrainsMono Nerd Font
- `herdr integration install claude` for each Claude profile dir (`~/.claude`, `~/.claude-*` with a `settings.json`)

After it finishes: open tmux and press prefix + `I` for tmux plugins.
