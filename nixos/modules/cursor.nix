# Cursor IDE, pinned to the latest upstream AppImage.
# nixpkgs-stable still ships 2.3.29; even nixos-unstable lags a few patches.
#
# To update: get the linux-x64 URL from
#   curl -sS 'https://www.cursor.com/api/download?platform=linux-x64&releaseTrack=latest'
# then:
#   nix store prefetch-file --hash-type sha256 --json '<downloadUrl>'
# and bump version / url / hash below.
{ pkgs, ... }:

let
  pname = "cursor";
  version = "3.21.18";

  src = pkgs.fetchurl {
    url = "https://downloads.cursor.com/production/c4730f7d93d787d9ab120af715999f0345ee5bc5/linux/x64/Cursor-${version}-x86_64.AppImage";
    hash = "sha256-GJNo02imuTBxq4pOQlADK/FqOWWTJMmwGv+8ZEodl4Q=";
  };

  appimageContents = pkgs.appimageTools.extractType2 {
    inherit pname version src;
  };
in
{
  environment.systemPackages = [
    (pkgs.appimageTools.wrapType2 {
      inherit pname version src;

      extraPkgs = pkgs: with pkgs; [
        libsecret
        libxkbcommon
        libxkbfile
        nss
        nspr
        libGL
        libdrm
        mesa
        gtk3
        glib
        pango
        cairo
        gdk-pixbuf
        at-spi2-atk
        at-spi2-core
        wayland
        libnotify
        cups
        libpulseaudio
        systemd
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        xorg.libxcb
      ];

      extraInstallCommands = ''
        install -Dm444 ${appimageContents}/cursor.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/cursor.desktop \
          --replace-fail 'Exec=cursor' 'Exec=${pname}'

        for size in 16 32 48 64 128 256 512 1024; do
          if [ -f ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/cursor.png ]; then
            install -Dm444 ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/cursor.png \
              $out/share/icons/hicolor/''${size}x''${size}/apps/co.anysphere.cursor.png
          fi
        done
        if [ -f ${appimageContents}/co.anysphere.cursor.png ]; then
          install -Dm444 ${appimageContents}/co.anysphere.cursor.png \
            $out/share/icons/hicolor/256x256/apps/co.anysphere.cursor.png
        fi
      '';

      meta = with pkgs.lib; {
        description = "AI-powered code editor built on VS Code";
        homepage = "https://cursor.com";
        changelog = "https://cursor.com/changelog";
        license = licenses.unfree;
        platforms = [ "x86_64-linux" ];
        mainProgram = "cursor";
        sourceProvenance = with sourceTypes; [ binaryNativeCode ];
      };
    })
  ];
}
