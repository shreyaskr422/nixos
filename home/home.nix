{ config, pkgs,inputs, ... }:

{
  imports = [
    ./modules/apps.nix
    ./modules/suckless.nix
    ./modules/btop.nix
    ./modules/noctalia.nix
    ./modules/packages.nix
  ];

  home.username = "moon";
  home.homeDirectory = "/home/moon";
  home.stateVersion = "26.05";
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
  };

   programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";
  };

  programs.bat.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
    LIBVIRT_DEFAULT_URI = "qemu:///system";
  };
}
