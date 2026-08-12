# Desktop: X11/GDM, GNOME (kept for your wife), Hyprland, fonts, portals, keymap.
{ config, pkgs, ... }:

{
  # Enable X11 support (needed for GNOME/GDM compatibility)
  services.xserver.enable = true;

  # GNOME Desktop (kept for your wife)
  # (these moved out from under services.xserver.* in recent NixOS)
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Hyprland binary cache
  nix.settings = {
    substituters = [
      "https://hyprland.cachix.org"
    ];

    trusted-public-keys = [
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Screen locker (sets up the PAM entry so hyprlock can actually unlock)
  programs.hyprlock.enable = true;

  # GPU: enable Intel hardware video acceleration (VA-API).
  # Without this, mpv/mpvpaper's hwdec has nothing to hand off to and falls
  # back to SOFTWARE decode, pegging a single CPU core (hot chassis, low
  # overall CPU graph). intel-media-driver is the modern "iHD" driver that
  # covers Meteor Lake / Arc (this machine's iGPU, PCI 8086:7d55).
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD VA-API driver (Gen8+ / Meteor Lake)
    ];
  };
  # Force the iHD driver so hwdec=auto resolves to it cleanly.
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  # Icon/glyph fonts for waybar and the terminal
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    font-awesome
    noto-fonts
    noto-fonts-color-emoji
  ];

  # Wayland portals (needed for screenshots, file pickers, screen sharing)
  xdg.portal = {
    enable = true;

    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };

  # Keyboard
  services.xserver.xkb = {
    layout = "au";
    variant = "";
  };
}
