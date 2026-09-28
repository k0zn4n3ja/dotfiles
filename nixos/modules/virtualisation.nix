# Virtualisation: libvirtd/KVM. (virt-manager, qemu, spice live in packages.nix.)
# Docker: so Next/Prisma native addons run in Alpine, not on the NixOS host.
{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;

  users.extraGroups.libvirtd.members = [
    "nixdt1"
  ];
  users.extraGroups.docker.members = [
    "nixdt1"
  ];
}
