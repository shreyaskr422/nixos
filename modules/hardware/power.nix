{ config, pkgs, ...}:

{
  hardware.cpu.amd.updateMicrocode = true;
  zramSwap.enable = true;
  services.fstrim.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  services.udev.extraRules = ''
  SUBSYSTEM=="power_supply", ATTR{online}=="0", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"
  SUBSYSTEM=="power_supply", ATTR{online}=="1", RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';



#  services.auto-cpufreq = {
#    enable = true;
#    settings = {
#      battery = {
#        governor = "powersave";
#        turbo_boost = 0;
#       energy_performance_preference = "power";
#        platform_profile = "quiet";
#      };
#      charger = {
#        governor = "performance";
#        turbo_boost = 1;
#        energy_performance_preference = "performance";
#      };
#    };
#  };

  powerManagement.powertop.enable = true;
  boot.kernelParams = [
    "pcie_aspm.policy=powersupersave"
    ];
}
