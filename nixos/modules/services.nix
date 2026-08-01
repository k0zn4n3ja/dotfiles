# System services: printing, secrets keyring, Tailscale.
{ config, pkgs, ... }:

{
  # Printing
  services.printing.enable = true;

  # Secrets keyring (used by 1Password, GNOME apps)
  services.gnome.gnome-keyring.enable = true;

  # Tailscale
  services.tailscale.enable = true;
}
