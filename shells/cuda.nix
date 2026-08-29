{ pkgs, cudaPkgs, ... }:

pkgs.mkShell {
  packages = [
    cudaPkgs.cudaPackages.cudatoolkit
    cudaPkgs.cudaPackages.cuda_nvcc
    cudaPkgs.cudaPackages.cuda_gdb
    cudaPkgs.cudaPackages.nsight_compute
    cudaPkgs.cudaPackages.nsight_systems

    pkgs.gcc
    pkgs.gnumake
    pkgs.cmake
    pkgs.ninja
    pkgs.gdb
    pkgs.pkg-config
  ];
   shellHook = ''
  export DEV_SHELL=cuda
  echo "CUDA development environment"

  export LD_LIBRARY_PATH="/run/opengl-driver/lib:$LD_LIBRARY_PATH"

  ${import ../flake/devshell-common.nix { inherit pkgs; }}
'';
 }
