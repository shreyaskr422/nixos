{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    # Systems programming
    gcc
    gnumake
    gdb
    lldb
    clang
    clang-tools
    cmake
    ninja
    pkg-config

    # Linux debugging / tracing
    strace
    ltrace
    perf

    # Binary / process / hardware inspection
    binutils
    file
    lsof
    procps
    util-linux
    pciutils
    usbutils

    # Networking diagnostics
    iproute2
    ethtool
    iputils
    openssh

    # General infrastructure utilities
    git
    curl
    wget
    jq
    yq
  ];

  shellHook = ''
    export DEV_SHELL=systems
    echo "Systems development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
