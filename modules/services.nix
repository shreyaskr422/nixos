{ ... }:

{
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.devmon.enable = true;
  programs.appimage = {
    enable = true;
    binfmt = true;
  };
}
