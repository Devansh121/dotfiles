#!/usr/bin/env bash
# Fresh-machine setup (Ubuntu 22.04+): install tools, then link configs via install.sh.
#   ./bootstrap.sh            -> everything
#   ./bootstrap.sh --no-rice  -> skip the i3 rice (i3, polybar, rofi, picom, dunst)
#   ./bootstrap.sh --dry-run  -> print what would be installed, change nothing
# Idempotent: anything already on PATH is skipped.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

rice=1 dry=0
for a in "$@"; do
  case $a in
    --no-rice) rice=0 ;;
    --dry-run) dry=1 ;;
    *) echo "unknown option: $a" >&2; exit 1 ;;
  esac
done

bin=$HOME/.local/bin opt=$HOME/.local/opt
mkdir -p "$bin" "$opt"
have() { command -v "$1" >/dev/null 2>&1; }
run() { if [ $dry -eq 1 ]; then echo "would: $*"; else echo "+ $*"; "$@"; fi; }
# download URL of the first asset in a repo's latest release matching a regex
gh_asset() { curl -fsSL "https://api.github.com/repos/$1/releases/latest" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4 | grep -E "$2" | head -1; }

# apt packages, only the missing ones
pkgs=(git curl unzip tmux terminator fzf ripgrep)
[ $rice -eq 1 ] && pkgs+=(i3 polybar rofi picom dunst)
missing=()
for p in "${pkgs[@]}"; do dpkg -s "$p" >/dev/null 2>&1 || missing+=("$p"); done
[ ${#missing[@]} -gt 0 ] && { run sudo apt-get update; run sudo apt-get install -y "${missing[@]}"; }

# neovim >= 0.11 (apt's is too old): official tarball into ~/.local/opt/nvim
if ! have nvim; then
  run sh -c "curl -fsSL https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz | tar -xz -C '$opt' && rm -rf '$opt/nvim' && mv '$opt/nvim-linux-x86_64' '$opt/nvim'"
  run ln -sf "$opt/nvim/bin/nvim" "$bin/nvim"
fi

if ! have lazygit; then
  url=$(gh_asset jesseduffield/lazygit '[Ll]inux_x86_64\.tar\.gz$')
  run sh -c "curl -fsSL '$url' | tar -xz -C '$bin' lazygit"
fi

have starship || run sh -c "curl -fsSL https://starship.rs/install.sh | sh -s -- -y -b '$bin'"
have ghostty || run sudo snap install ghostty --classic
have herdr || run sh -c "curl -fsSL https://herdr.dev/install.sh | sh"

[ -d "$HOME/.tmux/plugins/tpm" ] || run git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"

if ! fc-list : family | grep -i "JetBrainsMono Nerd" >/dev/null; then
  url=$(gh_asset ryanoasis/nerd-fonts '/JetBrainsMono\.zip$')
  fonts=$HOME/.local/share/fonts/JetBrainsMono
  run sh -c "mkdir -p '$fonts' && curl -fsSL -o /tmp/JetBrainsMono.zip '$url' && unzip -oq /tmp/JetBrainsMono.zip -d '$fonts' && rm /tmp/JetBrainsMono.zip && fc-cache -f"
fi

# configs
if [ $dry -eq 1 ]; then echo "would: ./install.sh"; else ./install.sh; fi

# herdr <-> Claude Code hook, for every Claude profile (~/.claude, ~/.claude-* with a settings.json)
if have claude || [ -x "$bin/claude" ]; then
  for d in "$HOME"/.claude "$HOME"/.claude-*; do
    [ -f "$d/settings.json" ] && run env CLAUDE_CONFIG_DIR="$d" "$(command -v herdr || echo "$bin/herdr")" integration install claude
  done
fi

echo "done. open tmux and press prefix + I to install tmux plugins."
