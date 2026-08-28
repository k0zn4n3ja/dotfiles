# Datadog Pup CLI (binary release from GitHub — not in nixpkgs).
# Same shape as zen-browser.nix: packaged here so packages.nix stays clean.
#
# To update: bump `version`, then grab the new tarball hash from
#   https://github.com/DataDog/pup/releases/download/v<ver>/pup_<ver>_checksums.txt
# and paste it into `sha256`.
{ config, pkgs, ... }:

let
  pup = pkgs.stdenv.mkDerivation rec {
    pname = "pup";
    version = "1.15.1";

    src = pkgs.fetchurl {
      url = "https://github.com/DataDog/pup/releases/download/v${version}/pup_${version}_Linux_x86_64.tar.gz";
      sha256 = "46c0b35517c6b70503e64e7449090221646cf30647d82d4d6434950433f7ba08";
    };

    # fetchurl leaves the tarball unextracted
    unpackPhase = ''
      tar xzf $src
    '';

    nativeBuildInputs = with pkgs; [ autoPatchelfHook ];
    buildInputs = with pkgs; [ stdenv.cc.cc.lib ];

    installPhase = ''
      runHook preInstall
      install -Dm755 pup $out/bin/pup
      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = [ pup ];
}
