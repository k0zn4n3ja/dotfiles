# Edit this configuration file to define what should be installed on
# your system. Help is available in the NixOS manual.
#
# This file is intentionally thin: it holds bootstrap + machine identity,
# and imports topic modules from ./modules/. Each module is the same
# { config, pkgs, ... }: { ... } shape; NixOS merges them all together.

{ config, pkgs, nixpkgs-unstable, ... }:

{
  imports = [
    ./hardware-configuration.nix

    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/shell.nix
    ./modules/services.nix
    ./modules/programs.nix
    ./modules/virtualisation.nix
    ./modules/packages.nix
  ];

  # escape hatch for non-nix managed
  # TODO can configure per-package allowance
  programs.nix-ld.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";

  # Enable networking
  networking.networkmanager.enable = true;

  # Timezone
  time.timeZone = "Australia/Brisbane";

  # Locale
  i18n.defaultLocale = "en_AU.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_AU.UTF-8";
    LC_IDENTIFICATION = "en_AU.UTF-8";
    LC_MEASUREMENT = "en_AU.UTF-8";
    LC_MONETARY = "en_AU.UTF-8";
    LC_NAME = "en_AU.UTF-8";
    LC_NUMERIC = "en_AU.UTF-8";
    LC_PAPER = "en_AU.UTF-8";
    LC_TELEPHONE = "en_AU.UTF-8";
    LC_TIME = "en_AU.UTF-8";
  };

  # User
  users.users.nixdt1 = {
    isNormalUser = true;
    description = "nixdt1";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Flakes replace channels for this machine.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic store GC so the disk doesn't fill up with old generations again.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Escape hatch for packages not yet in the stable channel: refer to them as
  # `unstable.<name>` anywhere pkgs is in scope. The nixpkgs-unstable input is
  # passed in from flake.nix and pinned in flake.lock.
  nixpkgs.overlays = [
    (final: prev: {
      unstable = import nixpkgs-unstable {
        inherit (prev.stdenv.hostPlatform) system;
        config.allowUnfree = true;
      };
    })
  ];

  # Keep this as your install version
  system.stateVersion = "25.11";
}
