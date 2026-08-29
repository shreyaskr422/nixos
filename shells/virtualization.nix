{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    qemu
    libvirt
    virt-manager

    dnsmasq
    bridge-utils
    swtpm

    OVMF

    virt-viewer
    spice
    spice-gtk
  ];

  shellHook = ''
    export DEV_SHELL=virtualization
    echo "Virtualization development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
