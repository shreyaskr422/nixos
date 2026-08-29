{ pkgs, qiskitAerGpu, ... }:

pkgs.mkShell {
  packages = [
    pkgs.python313
    pkgs.python313Packages.qiskit
    qiskitAerGpu
  ];

  shellHook = ''
    export DEV_SHELL=quantum-gpu
    echo "Quantum GPU development environment"

    export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
