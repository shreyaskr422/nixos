{config, lib, pkgs, ...}:

{
  services.supergfxd = {
    enable = true;
    settings = {
      always_reboot = true;
    };
  };
  systemd.services.supergfxd.path = [ pkgs.pciutils ];
  programs.rog-control-center.enable = true;

}
