{ inputs, ... }:
{
  perSystem =
    { pkgs, system, cudaPkgs, ... }:
    {
      packages.qiskit-aer-gpu =
        import ../packages/quantum/qiskit-aer-gpu.nix {
          inherit pkgs cudaPkgs;
        };
      packages.qiskit-machine-learning =
        import ../packages/quantum/qiskit-machine-learning.nix {
          inherit pkgs;
        };
    };
}
