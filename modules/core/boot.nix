{inputs, pkgs, config, lib, ...}:
{

  nixpkgs.overlays = [ inputs.nix-cachyos-kernel.overlays.pinned ];
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.configurationLimit = 3;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";

  boot.loader.elegant-grub2-theme = {
    enable = true;
    theme = "mojave";
    type = "blur";
    side = "right";
    color = "dark";
    screen = "1080p";
    logo = "system";
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-bore-lto-zen4;
  boot.kernelParams = [
    "loglevel=3"
    "splash"
    "quiet"
    "8250.nr_uarts=0"
    "nowatchdog"
    "gpiolib_acpi.run_edge_events_on_boot=0"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "mem_sleep_default=deep"
    "mem_encrypt=on"
    "kvm_amd.sev=1"
    "mt7921e.disable_aspm=Y"
  ];
}
