# System services: printing, secrets keyring, Tailscale.
{ config, pkgs, ... }:

{
  # Printing
  services.printing.enable = true;

  # Secrets keyring (used by 1Password, GNOME apps)
  services.gnome.gnome-keyring.enable = true;

  # Tailscale
  services.tailscale.enable = true;

  # Lid behaviour — desktop-replacement / clamshell:
  #   external monitor connected -> closing the lid keeps the machine running
  #                                 (fold it up, use only the external; the
  #                                 Hyprland monitor-policy switches displays)
  #   no external monitor        -> closing the lid suspends like a normal laptop
  # "Docked" = systemd sees a connected external output, so this hot-swaps:
  # plug the screen in and fold -> stays on; unplug -> next fold suspends.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";              # folded + no external -> sleep
    HandleLidSwitchDocked = "ignore";         # folded + external    -> stay on
    HandleLidSwitchExternalPower = "suspend"; # on AC, no external   -> still sleep on fold
  };
}
