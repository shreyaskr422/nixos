{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    python3
    python3Packages.numpy
    python3Packages.scipy
    python3Packages.pandas
    python3Packages.matplotlib
    python3Packages.scikit-learn
    python3Packages.jupyter
    python3Packages.ipython
  ];
  shellHook = ''
    export DEV_SHELL=ml
    echo "Classical ML development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
