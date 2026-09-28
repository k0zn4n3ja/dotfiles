#!/usr/bin/env python3
# DP-1 hotplug recovery.
#
# The USB-C -> HDMI 2.1 adapter in the KVM chain sometimes fails to retrain
# when the KVM switches back, leaving the monitor on "no signal" until manual
# replug. And while DP-1 is gone, Hyprland evacuates all workspaces onto the
# laptop panel and never brings them home.
#
# This watches Hyprland's event socket; when DP-1 reappears it:
#   1. re-asserts the mode and cycles DPMS to force a clean handshake
#   2. moves every workspace back onto DP-1

import json
import os
import socket
import subprocess
import time

RUNTIME = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
SIG = os.environ["HYPRLAND_INSTANCE_SIGNATURE"]
SOCK = f"{RUNTIME}/hypr/{SIG}/.socket2.sock"
MONITOR = "DP-1"
MODE = "5120x2160@45,0x0,1"


def hyprctl(*args):
    subprocess.run(["hyprctl", *args], check=False,
                   stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def workspaces_elsewhere():
    out = subprocess.run(["hyprctl", "workspaces", "-j"],
                         capture_output=True, text=True).stdout
    try:
        return [w["id"] for w in json.loads(out) if w["monitor"] != MONITOR]
    except (json.JSONDecodeError, KeyError):
        return []


def kick():
    time.sleep(2)                      # let the chain settle first
    hyprctl("keyword", "monitor", f"{MONITOR},{MODE}")
    time.sleep(1)
    hyprctl("dispatch", "dpms", "off", MONITOR)
    time.sleep(2)
    hyprctl("dispatch", "dpms", "on", MONITOR)
    time.sleep(1)
    for ws in workspaces_elsewhere():
        hyprctl("dispatch", "moveworkspacetomonitor", str(ws), MONITOR)


while True:
    try:
        with socket.socket(socket.AF_UNIX) as s:
            s.connect(SOCK)
            f = s.makefile("r", errors="replace")
            for line in f:
                if line.startswith(f"monitoradded>>{MONITOR}"):
                    kick()
    except OSError:
        time.sleep(5)                  # compositor restart etc; retry
