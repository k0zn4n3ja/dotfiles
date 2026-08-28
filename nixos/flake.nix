# Flake entrypoint. Replaces channels: nixpkgs + nixpkgs-unstable are pinned
# in flake.lock; bump deliberately with `nix flake update`.
# Build with: sudo nixos-rebuild switch --flake ~/dotfiles/nixos#nixos
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit nixpkgs-unstable; };
      modules = [ ./configuration.nix ];
    };
  };
}
