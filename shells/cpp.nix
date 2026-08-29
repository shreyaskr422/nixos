{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    gcc
    gnumake
    cmake
    ninja
    pkg-config
    gdb
    lldb
    clang-tools
  ];
    shellHook = ''
    export DEV_SHELL=cpp
    echo "C/C++ development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
