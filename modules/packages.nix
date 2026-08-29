{config, lib, pkgs,inputs, ...}:

let
  unstable-pkgs = import inputs.nixpkgs-unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in

{
  environment.systemPackages = with pkgs; [
    hyprcursor
    wl-clipboard
    libva-utils
    networkmanagerapplet
    brightnessctl
    pamixer
    alsa-utils
    gtk3
    xcursorgen
  ];
}
