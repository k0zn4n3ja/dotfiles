# Proton Drive CLI (official binary — not in nixpkgs yet).
# Same shape as pup.nix: packaged here so packages.nix stays clean.
#
# Needs libsecret + an unlocked Secret Service (gnome-keyring is already
# enabled in services.nix). Login: `proton-drive auth login`.
#
# To update: bump `version`, then
#   nix-prefetch-url https://proton.me/download/drive/cli/<ver>/linux-x64/proton-drive
# and paste the new hash into `sha256`.
{ config, pkgs, ... }:

let
  secretsLibs = with pkgs; [
    libsecret
    glib
    pcre2
    libffi
    libselinux
    libgpg-error
    util-linux.lib
    libgcrypt.lib
  ];

  proton-drive-cli = pkgs.stdenv.mkDerivation rec {
    pname = "proton-drive-cli";
    version = "0.8.0";

    src = pkgs.fetchurl {
      url = "https://proton.me/download/drive/cli/${version}/linux-x64/proton-drive";
      sha256 = "0dbpaz77srvpgjkg6a9kb59prbcrrlpg1rhpvf82g2cwf5qxfhwl";
    };

    dontUnpack = true;
    dontStrip = true; # bun compile embeds the JS bundle in the ELF

    nativeBuildInputs = with pkgs; [ autoPatchelfHook makeWrapper ];
    buildInputs = secretsLibs ++ (with pkgs; [ stdenv.cc.cc.lib ]);

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/proton-drive
      wrapProgram $out/bin/proton-drive \
        --suffix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath secretsLibs}" \
        --suffix PATH : ${pkgs.lib.makeBinPath [ pkgs.xdg-utils ]}
      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = [ proton-drive-cli ];
}
