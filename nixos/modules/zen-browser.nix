# Zen Browser (binary release from GitHub — not in nixpkgs).
# Defined as its own package here and installed via systemPackages, so the
# main packages.nix doesn't have to carry this wall of buildInputs.
#
# To update: bump `version`, then run
#   nix-prefetch-url https://github.com/zen-browser/desktop/releases/download/<ver>/zen.linux-x86_64.tar.xz
# and paste the new hash into `sha256`.
{ config, pkgs, ... }:

let
  zen-browser = pkgs.stdenv.mkDerivation rec {
    pname = "zen-browser";
    version = "1.21.9b";

    src = pkgs.fetchurl {
      url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen.linux-x86_64.tar.xz";
      sha256 = "00bfpynr48w6p3c3s10d5bq3c63vfi6c5lpb7vax18i1qiki8fzq";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
      wrapGAppsHook3
      makeWrapper
    ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      alsa-lib
      at-spi2-atk
      at-spi2-core
      atk
      cairo
      cups
      dbus
      dbus-glib
      fontconfig
      freetype
      gdk-pixbuf
      glib
      gtk3
      libGL
      libdrm
      libnotify
      libpulseaudio
      libxkbcommon
      mesa
      nspr
      nss
      pango
      pipewire
      udev
      wayland
      zlib
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrandr
      xorg.libXrender
      xorg.libXt
      xorg.libXtst
      xorg.libxcb
    ];

    # gApps wrapper is applied manually in installPhase
    dontWrapGApps = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/opt/zen $out/bin
      cp -r ./* $out/opt/zen/

      makeWrapper $out/opt/zen/zen $out/bin/zen \
        "''${gappsWrapperArgs[@]}" \
        --set MOZ_ENABLE_WAYLAND 1 \
        --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
          pkgs.libGL
          pkgs.libpulseaudio  # audio playback — Firefox/cubeb dlopens libpulse.so.0 at runtime
          pkgs.pipewire       # WebRTC / screenshare audio
        ]}"

      install -Dm644 $out/opt/zen/browser/chrome/icons/default/default128.png \
        $out/share/icons/hicolor/128x128/apps/zen.png 2>/dev/null || true

      mkdir -p $out/share/applications
      cat > $out/share/applications/zen.desktop <<EOF
      [Desktop Entry]
      Name=Zen Browser
      Exec=$out/bin/zen %U
      Icon=zen
      Type=Application
      Categories=Network;WebBrowser;
      MimeType=text/html;x-scheme-handler/http;x-scheme-handler/https;
      StartupWMClass=zen
      EOF
      runHook postInstall
    '';
  };
in
{
  environment.systemPackages = [ zen-browser ];
}
