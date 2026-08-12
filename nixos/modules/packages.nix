# All bare packages installed system-wide (environment.systemPackages).
# Programs that have dedicated NixOS modules live in programs.nix / desktop.nix
# instead. The Zen browser derivation is imported from ./zen-browser.nix.
{ config, pkgs, ... }:

{
  imports = [
    ./zen-browser.nix
  ];

  # librewolf currently ships a version flagged insecure; allow it explicitly.
  # (Remove this block if you drop librewolf below.)
  nixpkgs.config.permittedInsecurePackages = [
    "librewolf-152.0.2-1"
    "librewolf-unwrapped-152.0.2-1"
  ];

  environment.systemPackages = with pkgs; [
    vim

    #
    # Gnome stuff
    #
    gnome-tweaks
    gnomeExtensions.hide-top-bar
    gnomeExtensions.unite
    gnomeExtensions.dash-to-dock
    gnomeExtensions.arcmenu
    gnomeExtensions.vitals
    gnomeExtensions.net-speed-simplified
    gnomeExtensions.caffeine
    # end Gnome stuff

    #
    # Hyprland / Wayland stuff
    #
    mpvpaper
    hyprpaper
    waybar
    rofi
    swww
    wl-clipboard
    grim
    slurp
    # --- desktop essentials so Hyprland "just works" ---
    mako            # notification daemon
    libnotify       # notify-send + notification client lib
    hyprpolkitagent # graphical auth prompts (1Password, polkit)
    hypridle        # idle -> lock/dpms
    brightnessctl   # used by the brightness keybinds
    playerctl       # used by the media keybinds
    pavucontrol     # audio mixer GUI
    cliphist        # clipboard history
    wtype           # cliphist paste helper
    swappy          # screenshot annotate/edit
    grimblast       # convenient screenshot wrapper
    wf-recorder     # region/screen video recording (Super+Shift+R toggle)
    pulseaudio      # client tools only (pactl) so wf-recorder can grab desktop audio; no daemon (PipeWire stays)
    ffmpeg          # grabs a frame of the live wallpaper for the hyprlock background
    libva-utils     # `vainfo` — verify GPU video decode (VA-API/iHD) is active
    nautilus        # file manager (already via GNOME, pinned here too)
    networkmanagerapplet
    btop            # terminal system monitor (CLI)
    eww             # desktop widgets (stats card + music player)
    cava            # audio visualizer (streamed into the eww music player)

    # --- theming: dark GTK + nicer icons ---
    papirus-icon-theme  # folder/file icon set (has Papirus-Dark)
    papirus-folders     # CLI to recolor Papirus folders

    #
    # Browsers
    #
    librewolf
    brave

    #
    # VPN / Communication
    #
    protonvpn-gui
    unstable.proton-vpn-cli # not in 25.11 yet
    thunderbird
    protonmail-bridge
    signal-desktop
    telegram-desktop
    slack
    zoom-us

    #
    # Virtualisation
    #
    virt-manager
    qemu_kvm
    spice-gtk

    #
    # File sync
    #
    (pkgs.stdenv.mkDerivation {
      pname = "rclone";
      version = "1.70.1";

      src = pkgs.fetchzip {
        url = "https://downloads.rclone.org/v1.70.1/rclone-v1.70.1-linux-amd64.zip";
        sha256 = "KVJBpSf4oE3oKpPf9JIDEB10ZUWfZqObsfsg6ppa2jc=";
      };

      installPhase = ''
        mkdir -p $out/bin
        cp rclone $out/bin/
      '';
    })

    #
    # Media
    #
    transmission_4-gtk
    vlc
    masterpdfeditor

    #
    # Development
    #
    neovim
    vscodium
    git
    gh
    jq
    nodejs_22
    ollama
    opencode

    # --- LazyVim: LSP servers + toolchains via Nix (no Mason needed) ---
    gcc                         # C compiler for treesitter parser builds
    tree-sitter                 # treesitter CLI (LazyVim needs it; Mason usually provides it)
    ripgrep                     # telescope grep
    fd                          # telescope file find
    lazygit                     # <leader>gg git UI
    lua-language-server         # Lua LSP (LazyVim configs are Lua)
    stylua                      # Lua formatter
    shfmt                       # shell formatter
    # Go
    go
    gopls
    gofumpt
    # TypeScript / JS
    vtsls
    typescript-language-server
    nodePackages.typescript
    prettierd
    # C# (.NET): modern roslyn LSP + combined SDKs (8/9/10) so every repo's
    # global.json pin resolves. roslyn-ls handles new SDK-style projects that
    # OmniSharp chokes on (e.g. .NET 10 + Microsoft.Testing.Platform).
    roslyn-ls
    (with dotnetCorePackages; combinePackages [ sdk_8_0 sdk_9_0 sdk_10_0 ])
    # Rust LSP (rust-analyzer) + cargo/rustc already installed above

    #
    # Terminal
    #
    alacritty
    tmux
    iamb
    kitty
    foot
    fzf

    #
    # Rust
    #
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    #
    # Azure
    #
    (azure-cli.withExtensions [
      azure-cli.extensions.aks-preview
    ])

    #
    # Remote access
    #
    anydesk

    #
    # Games / Windows compatibility
    #
    wineWowPackages.stable
    winetricks
  ];
}
