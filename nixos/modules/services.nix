# System services: printing, secrets keyring, Tailscale, Bluetooth.
{ config, pkgs, ... }:

let
  lowBatteryAlert = pkgs.writeShellScriptBin "low-battery-alert" ''
    export PATH="${pkgs.lib.makeBinPath (with pkgs; [
      coreutils
      libnotify
      pulseaudio
    ])}:$PATH"

    shopt -s nullglob
    batteries=(/sys/class/power_supply/BAT*)
    (( ''${#batteries[@]} > 0 )) || exit 0

    battery="''${batteries[0]}"
    marker="''${XDG_RUNTIME_DIR:-/tmp}/low-battery-alerted"
    sound="${pkgs.sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message-new-instant.oga"
    speaker="alsa_output.pci-0000_00_1f.3.analog-stereo"

    while true; do
      status=$(<"$battery/status")
      capacity=$(<"$battery/capacity")

      if [[ "$status" == "Discharging" && "$capacity" -le 15 ]]; then
        if [[ ! -e "$marker" ]]; then
          notify-send \
            --app-name="Battery" \
            --urgency=critical \
            --icon=battery-caution-symbolic \
            "Battery low" \
            "Battery is at ''${capacity}%. Connect the charger."
          paplay --device="$speaker" "$sound" || paplay "$sound" || true
          touch "$marker"
        fi
      elif [[ "$status" != "Discharging" ]]; then
        rm -f "$marker"
      fi

      sleep 30
    done
  '';
in
{
  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Printing
  services.printing.enable = true;

  # Secrets keyring (used by 1Password, GNOME apps)
  services.gnome.gnome-keyring.enable = true;

  # Tailscale
  services.tailscale.enable = true;

  # Loose reverse-path check: allow Tailscale's direct-path replies to arrive
  # over Wi-Fi while Proton VPN is the default route (Tailscale's NixOS docs
  # recommend this; still drops traffic from nonexistent source interfaces).
  networking.firewall.checkReversePath = "loose";

  # SSH — reachable over tailscale + LAN, password auth (default) for now.
  services.openssh.enable = true;

  # Lid behaviour — always-on clamshell:
  #   closing the lid never suspends, docked or not, on AC or battery.
  #   The machine lives folded on a stand behind a KVM; the monitor
  #   disappearing (KVM switch-away) must not put it to sleep.
  #   Battery idle-suspend in hypridle is the only remaining sleep trigger.
  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";               # folded on battery      -> stay on
    HandleLidSwitchDocked = "ignore";         # folded + external      -> stay on
    HandleLidSwitchExternalPower = "ignore";  # folded on AC           -> stay on
  };

  # One notification and chime when a discharge reaches 15%. The marker is
  # cleared when power is connected, arming the alert for the next discharge.
  systemd.user.services.low-battery-alert = {
    description = "Notify once when the battery reaches 15%";
    wantedBy = [ "default.target" ];
    after = [
      "pipewire.service"
      "wireplumber.service"
    ];

    serviceConfig = {
      ExecStart = "${lowBatteryAlert}/bin/low-battery-alert";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
