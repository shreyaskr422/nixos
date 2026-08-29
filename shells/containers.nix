{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    podman
    podman-compose
    buildah
    skopeo
    dive
    crane
    jq
    yq
    curl
  ];

  shellHook = ''
    export DEV_SHELL=containers
    echo "Container development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
