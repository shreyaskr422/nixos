{config ,lib, pkgs, ...}:

{
   programs.mangowc.enable = true;
   security.polkit.enable = true;
   programs.uwsm.enable = true;

  services = {
    xserver = {
      enable = true;
      autoRepeatDelay = 130;
      autoRepeatInterval = 12;
      windowManager.dwm = {
        enable = true;
	package = pkgs.dwm.overrideAttrs (oldAttrs: {
              src = ../config/dwm-flexipatch;

              buildInputs = oldAttrs.buildInputs ++ [
                pkgs.libX11
                pkgs.libxcb
                pkgs.libXinerama
                pkgs.fontconfig
                pkgs.libXft
           ];
        });
      };
    };
    picom.enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = true;
  };

   xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-wlr
	xdg-desktop-portal-gtk
       ];
      configPackages = [ 
      pkgs.hyprland
      pkgs.mangowc
    ];
   config = {
      Hyprland.default = lib.mkForce [ "hyprland" "gtk" ];
      mango.default = lib.mkForce [ "wlr" "gtk" ];
      };
   };

  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
