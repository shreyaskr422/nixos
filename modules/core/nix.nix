{config, lib, pkgs, ...}:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;
  hardware.enableRedistributableFirmware = true;
  nix.optimise.automatic = true;
  programs.nix-ld.enable = true;

  nix.settings = {
    max-jobs = "auto";
    cores = 0;
    max-substitution-jobs = 32;
    http-connections = 32;
    download-buffer-size = 268435456;
  };


  nix.settings.extra-substituters = [
     "https://noctalia.cachix.org"
     "https://attic.xuyh0120.win/lantian"
  ];
  nix.settings.extra-trusted-public-keys = [
     "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
     "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc="
  ];

  system.activationScripts.trimGenerations = {
    supportsDryActivation = true;
    text = ''
      echo "Trimming system profiles to keep exactly the last 3..."
      ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --delete-generations +3
      ${pkgs.nix}/bin/nix-collect-garbage
    '';
  };
}
