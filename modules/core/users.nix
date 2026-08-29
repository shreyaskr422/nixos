{config, lib, pkgs, ...}:

{
 users.users.moon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "libvirtd" "input" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  programs.zsh.autosuggestions.enable = true;
  programs.zsh.syntaxHighlighting.enable = true;
}
