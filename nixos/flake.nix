# Flake entrypoint. Replaces channels: nixpkgs + nixpkgs-unstable are pinned
# in flake.lock; bump deliberately with `nix flake update`.
# Build with: sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs lags upstream iamb by several releases; bump the tag to update.
    iamb.url = "github:ulyssa/iamb/v0.13.1";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, iamb }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nixpkgs-unstable iamb; };
      modules = [ ./configuration.nix ];
    };
  };
}
