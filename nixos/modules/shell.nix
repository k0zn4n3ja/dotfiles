# Shell: fish + starship prompt + zoxide + fzf key bindings.
# (The user's login shell is set to fish in configuration.nix.)
{ config, pkgs, ... }:

{
  # Fish shell (autosuggestions + syntax highlighting out of the box)
  # + starship prompt. Both auto-integrate with fish.
  programs.fish.enable = true;
  programs.starship.enable = true;

  # zoxide: smart 'cd' — `z <partial-dir-name>` jumps to frecent dirs.
  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  # fzf key bindings in fish: Ctrl-R fuzzy history, Ctrl-T files, Alt-C cd.
  programs.fish.interactiveShellInit = ''
    fzf --fish | source
  '';
}
