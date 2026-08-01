# User-facing programs enabled as NixOS modules (as opposed to bare packages):
# Firefox, Steam, 1Password.
{ config, pkgs, ... }:

{
  # Browsers
  programs.firefox.enable = true;

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # 1Password
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [
      "nixdt1"
    ];
  };
}
