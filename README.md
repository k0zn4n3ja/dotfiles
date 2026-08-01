# dotfiles

NixOS + Hyprland config for `nixos` (Intel Core Ultra 5 125H laptop).
The live locations are **symlinks into this repo**, so the repo is always the
source of truth — edit configs in place as normal, then commit.

## Layout

```
nixos/          -> symlinked from /etc/nixos   (system config; sudo to edit)
config/         -> symlinked from ~/.config/*  (the rice)
  hypr eww waybar fish nvim foot mako rofi btop cava
install.sh      recreates all the symlinks on a fresh machine
```

## Daily use

Nothing special. Edit a config where it lives (`~/.config/hypr/...`,
`/etc/nixos/...`), then back it up:

```sh
cd ~/dotfiles && git add -A && git commit -m "tweak X" && git push
```

## Recover on a new machine

```sh
# after a fresh NixOS install, as your user:
git clone git@github.com:<you>/dotfiles.git ~/dotfiles
~/dotfiles/install.sh          # links ~/.config/* and prints the nixos steps

# then, for the system config (hardware config is machine-specific!):
sudo nixos-generate-config --show-hardware-config > ~/dotfiles/nixos/hardware-configuration.nix
sudo mv /etc/nixos /etc/nixos.orig
sudo ln -s ~/dotfiles/nixos /etc/nixos
sudo nixos-rebuild switch
```

## Notes

- `nixos/hardware-configuration.nix` is specific to *this* laptop's disks —
  regenerate it on new hardware (the recovery steps above do this).
- Secrets (browser profiles, 1Password, Signal, tokens, keys) are intentionally
  **not** tracked. Only the allowlisted rice dirs live here. Keep it that way.
