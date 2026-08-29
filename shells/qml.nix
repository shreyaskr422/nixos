{ pkgs, cudaPkgs, qiskitMachineLearning, ... }:

let
  python = cudaPkgs.python313.withPackages (ps: with ps; [
    jax
    jaxlib
    jax-cuda12-plugin
    jax-cuda12-pjrt

    qiskit
    qiskit-aer
    qiskitMachineLearning
    numpy
    scipy
    scikit-learn
    matplotlib
  ]);
in

cudaPkgs.mkShell {
  packages = [
    python
  ];

  shellHook = ''
    export DEV_SHELL=qml
    echo "Quantum Machine Learning development environment"

    export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
