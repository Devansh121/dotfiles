#!/usr/bin/env bash
# Symlink dotfile packages into $HOME. Stow-style layout: <pkg>/<path-under-home>.
#   ./install.sh            -> link every package
#   ./install.sh nvim tmux  -> link only those
# Existing real files are moved to <file>.bak.<timestamp>; existing symlinks are replaced.
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"
ts=$(date +%Y%m%d-%H%M%S)
pkgs=("$@"); [ ${#pkgs[@]} -eq 0 ] && pkgs=(*/)
for pkg in "${pkgs[@]}"; do
  pkg=${pkg%/}; [ -d "$pkg" ] || { echo "skip: no package '$pkg'"; continue; }
  while IFS= read -r -d '' src; do
    rel=${src#"$pkg"/}; dst="$HOME/$rel"
    mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then rm "$dst"
    elif [ -e "$dst" ]; then mv "$dst" "$dst.bak.$ts"; echo "backed up $dst"; fi
    ln -s "$PWD/$src" "$dst"; echo "linked  $dst"
  done < <(find "$pkg" -type f -print0)
done
