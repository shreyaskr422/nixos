{config, lib, pkgs, ...}:

{
   services.blueman.enable = true;
   hardware.bluetooth ={
	enable = true;
	powerOnBoot = false;
	settings = {
        General = {
           Experimental = true;
	   ControllerMode = "dual";
           FastConnectable = true;
	   };
      };
  };

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    jack.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;

    extraConfig.pipewire."99-hires-audio" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.allowed-rates" = [ 44100 48000 88200 96000 192000];
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 1024;
        "default.clock.max-quantum" = 2048;
      };
    };

    extraConfig.pipewire-pulse."99-pulse-low-latency" = {
      "pulse.properties" = { "pulse.min.quantum" = "1024/48000"; };
    };
  };

  systemd.user.services.pipewire.restartIfChanged = true;
}
