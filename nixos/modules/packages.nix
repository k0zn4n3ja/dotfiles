# All bare packages installed system-wide (environment.systemPackages).
# Programs that have dedicated NixOS modules live in programs.nix / desktop.nix
# instead. Custom derivations (zen, pup, proton-drive-cli) are imported below.
{ config, pkgs, ... }:

{
  imports = [
    ./zen-browser.nix
    ./cursor.nix
    ./pup.nix
    ./proton-drive-cli.nix
  ];

  # librewolf currently ships a version flagged insecure; allow it explicitly.
  # (Remove this block if you drop librewolf below.)
  nixpkgs.config.permittedInsecurePackages = [
    "librewolf-152.0.2-1"
    "librewolf-unwrapped-152.0.2-1"
  ];

  # Switch JDKs with: export JAVA_HOME=$JAVA_HOME_17  (or _11 / _25)
  environment.sessionVariables = {
    JAVA_HOME_11 = "${pkgs.temurin-bin-11}";
    JAVA_HOME_17 = "${pkgs.temurin-bin-17}";
    JAVA_HOME_25 = "${pkgs.temurin-bin-25}";
    JAVA_HOME = "${pkgs.temurin-bin-25}";
  };

  environment.systemPackages = with pkgs; [
    vim
    bubblewrap       # Codex Linux sandbox helper (`bwrap`)

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
    unstable.voxtype-vulkan # offline push-to-talk dictation (thumb button); Wispr Flow has no Linux client. CPU build took ~10s per sentence, Vulkan ~1s
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
    # Vivaldi: only Chromium-based browser that can auto-hide tabs + address bar (reveal on hover).
    # Codecs for H.264/AAC (X.com etc.), Widevine for Netflix/Spotify.
    (vivaldi.override { proprietaryCodecs = true; enableWidevine = true; })

    #
    # VPN / Communication
    #
    protonvpn-gui
    unstable.proton-vpn-cli # not in 25.11 yet
    thunderbird
    protonmail-bridge
    unstable.signal-desktop # stable lags and Signal refuses to run old clients
    telegram-desktop
    discord
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
    gnumake
    jq
    python3
    gitleaks
    nodejs_22
    ollama
    opencode
    unstable.grok-build # xAI Grok CLI; not in 25.11
    # EatClub JVM/TF: 25 is default `java`. 11/17 via JAVA_HOME_11 / JAVA_HOME_17.
    temurin-bin-25
    maven
    terraform

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
    tmux
    iamb
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
    # Cloud CLIs
    #
    awscli2
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
