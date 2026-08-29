{
  description = "SoS";

inputs = {
  nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  flake-parts.url =
    "github:hercules-ci/flake-parts";

  home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  nix-cachyos-kernel = {
    url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  elegant-grub2-themes = {
    url = "github:vinceliuice/elegant-grub2-themes";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  noctalia = {
    url = "github:noctalia-dev/noctalia/cachix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  nur = {
    url = "github:nix-community/NUR";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};

outputs = inputs@{ self, nixpkgs, home-manager, elegant-grub2-themes, ... }:
  inputs.flake-parts.lib.mkFlake { inherit inputs; } {

    systems = [
      "x86_64-linux"
    ];

    perSystem = { system, ... }: {
         _module.args.cudaPkgs = import nixpkgs {
         inherit system;
         config.allowUnfree = true;
        };
     };

    imports = [
      ./flake/devshells.nix
      ./flake/packages.nix
      ./flake/checks.nix
      ./flake/kubernetes.nix
      ./flake/platform.nix
    ];

    flake = {
      nixosConfigurations.SoS = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          { nixpkgs.hostPlatform = "x86_64-linux"; }
          ./hosts/SoS/default.nix
          inputs.nur.modules.nixos.default
          elegant-grub2-themes.nixosModules.default
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.moon =
              import ./home/home.nix;
          }
        ];
      };
    };
  };
}
