# User-facing programs enabled as NixOS modules (as opposed to bare packages):
# 1Password.
{ config, pkgs, ... }:

{
  # 1Password
  programs._1password.enable = true;

  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [
      "nixdt1"
    ];
  };
}
