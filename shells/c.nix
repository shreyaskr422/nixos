{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gnumake
    gdb
    pkg-config
    freetype
    libX11
    libXinerama
    libXft
    libXrender
    libXext
    libxcb
    xcbutil
  ];

  shellHook = ''
    export DEV_SHELL=c
    echo "C development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
