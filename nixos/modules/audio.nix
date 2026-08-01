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
  };
}
