#!/usr/bin/env bash
# Recreate the symlinks from this repo into their live locations.
# Safe to re-run: an existing real (non-symlink) target is moved aside to
# <name>.pre-dotfiles before linking.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG="$HOME/.config"
mkdir -p "$CONFIG"

link() { # link <src-in-repo> <live-path>
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    mv "$dst" "$dst.pre-dotfiles"
    echo "  backed up $dst -> $dst.pre-dotfiles"
  fi
  ln -sfn "$src" "$dst"
  echo "  linked $dst -> $src"
}

echo "Linking ~/.config dotfiles..."
for d in "$REPO"/config/*/; do
  name="$(basename "$d")"
  link "$REPO/config/$name" "$CONFIG/$name"
done

cat <<EOF

Home dotfiles linked.

To restore the NixOS system config on this machine:
  # 1. regenerate hardware config for THIS hardware (don't reuse the old one):
  sudo nixos-generate-config --show-hardware-config > "$REPO/nixos/hardware-configuration.nix"
  # 2. point /etc/nixos at the repo:
  sudo mv /etc/nixos /etc/nixos.orig && sudo ln -s "$REPO/nixos" /etc/nixos
  # 3. build it:
  sudo nixos-rebuild switch
EOF
