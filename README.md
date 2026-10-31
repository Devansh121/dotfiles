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
| ghostty  | Monokai Pro Spectrum (true red in slots 1/9), Hack Nerd Font Mono, orange block cursor, cursor shaders (see below) |
| starship | Tokyo Night prompt                                     |
| lazygit  | config                                                 |
| herdr    | prefix `C-Space`, `C-S-Left/Right` switch workspaces, dracula theme |
| terminator | same theme, font and cursor as ghostty, CursorFX cursor-trail plugin (see below), resize_left/right unbound so herdr gets `C-S-Left/Right` |
| htop / mtop | detailed CPU time, freq/temp, disk/net/PSI meters, extra columns (threads, swap, IO, OOM), tree view |
| btop     | Tokyo Night theme (bundled, not shipped by btop 1.2.3), 1s refresh, process tree, per-disk IO graphs, user/system CPU graphs |

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

- apt: git, curl, unzip, tmux, terminator, fzf, ripgrep, htop, btop (+ i3, polybar, rofi, picom, dunst unless `--no-rice`)
- nvim (latest release tarball, apt's is too old), lazygit, starship, herdr → `~/.local/bin`
- ghostty (snap), tpm, Hack + JetBrainsMono Nerd Fonts (Hack for ghostty/terminator, JetBrainsMono for the i3 rice)
- `herdr integration install claude` for each Claude profile dir (`~/.claude`, `~/.claude-*` with a `settings.json`)

After it finishes: open tmux and press prefix + `I` for tmux plugins.

## i3 profiles
`~/.config/i3/config` only does `include active.conf`. Two profiles ship:

- `prime` — ThePrimeagen's i3 config (Alt as mod, stock i3status bar, rofi, flameshot), adapted for ghostty/pactl/brightnessctl.
- `rice`  — the Tokyo Night setup: Super as mod, polybar, picom, dunst, scratchpad terminal, media keys.

```sh
i3-profile          # show active + available
i3-profile prime    # switch and reload i3
```
Log out and pick the **i3** session at the login screen to use either.

## htop / mtop
- `htop` is apt's 3.0.5 (config `~/.config/htop/htoprc`).
- `mtop` is htop 3.5.3 built from source into `~/.local/opt/htop` by `bootstrap.sh`, with its own config `~/.config/mtop/htoprc` (newer htoprc format would break 3.0.5). Adds per-core CPU temperature on Ryzen, tabs (Main / I/O / Memory / Sched), disk rate + busy meters.
- Both write changes made in the UI through the symlink, so they land in this repo.

## Cursor effects
- **ghostty**: `custom-shader` loads `shaders/cursor_warp.glsl` (the cursor smears along its path when it jumps) and `shaders/ripple_cursor.glsl` (a ring when the cursor changes shape), from [sahaj-b/cursor-shaders](https://github.com/sahaj-b/cursor-shaders) (MIT, `shaders/LICENSE`).
- **terminator**: `plugins/cursor_fx.py` (CursorFX), enabled by `enabled_plugins = CursorFX` in the config. It paints the same warp trail with Cairo over each terminal, and skips it while an app has the cursor hidden. The ripple is ported but off (`RIPPLE = False`).
- Terminator loads plugins only when its process starts. New windows join the running process, so quit every window to pick up plugin changes, or run `terminator -u` for a separate process.
- Cost on this laptop: the plugin uses about 1% of one core while typing. The ghostty snap can't load NVIDIA's EGL driver here and renders on the CPU (Mesa llvmpipe), so its always-on shader animation uses several cores.
