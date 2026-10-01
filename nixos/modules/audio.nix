# Audio: PipeWire (with PulseAudio compatibility), rtkit for realtime priority.
{ config, pkgs, ... }:

{
  # Sound — PulseAudio disabled in favour of PipeWire below.
  services.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # x11-bell busy-loops the daemon (90% CPU, graph stalls) when Xwayland's :0 dies.
    extraConfig.pipewire."10-no-x11-bell"."context.properties"."module.x11.bell" = false;
  };
}
