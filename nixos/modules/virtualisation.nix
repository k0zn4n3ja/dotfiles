# Virtualisation: libvirtd/KVM. (virt-manager, qemu, spice live in packages.nix.)
# Docker: so Next/Prisma native addons run in Alpine, not on the NixOS host.
{ config, pkgs, ... }:

{
  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.docker.package = pkgs.docker_29;
  # / is a 98G partition; /home has the free space.
  virtualisation.docker.daemon.settings.data-root = "/home/docker";
  systemd.services.docker.unitConfig.RequiresMountsFor = "/home/docker";
  # Containers started with --cgroup-parent ec-stack.slice share this cap, 6 of 18 threads (the local Floci stack uses it).
  systemd.slices.ec-stack.sliceConfig = { MemoryMax = "17G"; MemoryHigh = "15G"; MemorySwapMax = "3G"; CPUQuota = "600%"; };
  # Compressed swap in RAM: memory pressure slows the machine instead of killing processes.
  zramSwap.enable = true;

  users.extraGroups.libvirtd.members = [
    "nixdt1"
  ];
  users.extraGroups.docker.members = [
    "nixdt1"
  ];
}
