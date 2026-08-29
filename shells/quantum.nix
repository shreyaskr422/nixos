{ pkgs, ... }:

let
  python = pkgs.python313.withPackages (ps: with ps; [
    qiskit
    qiskit-aer
    numpy
    scipy
    matplotlib
  ]);
in

pkgs.mkShell {
  packages = [
    python
  ];

  shellHook = ''
    export DEV_SHELL=quantum
    echo "Quantum computing development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
