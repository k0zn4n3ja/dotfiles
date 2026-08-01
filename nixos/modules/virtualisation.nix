# Virtualisation: libvirtd/KVM. (virt-manager, qemu, spice live in packages.nix.)
{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;

  users.extraGroups.libvirtd.members = [
    "nixdt1"
  ];
}
