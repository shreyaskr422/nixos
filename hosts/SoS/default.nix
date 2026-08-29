{ ... }:

{
  imports = [
    ./hardware-configuration.nix

    ../../modules/core/nix.nix
    ../../modules/core/boot.nix
    ../../modules/core/users.nix

    ../../modules/hardware/asus.nix
    ../../modules/hardware/graphics.nix
    ../../modules/hardware/power.nix

    ../../modules/desktop/desktop.nix
    ../../modules/desktop/ly.nix

    ../../modules/network/networking.nix
    ../../modules/network/dns.nix

    ../../modules/virtualization/virtualization.nix

    ../../modules/containers/containers.nix

    ../../modules/audio.nix
    ../../modules/services.nix
    ../../modules/packages.nix
    ../../modules/fonts.nix
  ];

  networking.hostName = "SoS";
  time.timeZone = "Asia/Kolkata";
  system.stateVersion = "26.05";
}
