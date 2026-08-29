{ config, lib, pkgs, ...}:

{

 hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

 hardware.nvidia-container-toolkit = {
    enable = true;
    mount-nvidia-executables = false;
 };
  
  hardware.nvidia = {
    dynamicBoost.enable = true;
    modesetting.enable = true;
    powerManagement.enable = true;
    nvidiaPersistenced = false;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    nvidiaSettings = true;
  };

  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  environment.variables = {
    AMD_VULKAN_ICD = "RADV";
    NIXOS_OZONE_WL = "1";
    LIBVA_DRIVER_NAME = "nvidia";
    __GL_VRR_ALLOWED = "1";
    __GL_GSYNC_ALLOWED = "1";
  };
}
