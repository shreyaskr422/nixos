{ inputs, ... }:
{
  perSystem =
    { pkgs, system, config, cudaPkgs, ... }:
    {
      devShells = {
        c = import ../shells/c.nix {
          inherit pkgs;
        };
        cpp = import ../shells/cpp.nix {
          inherit pkgs;
        };
        ml = import ../shells/ml.nix {
          inherit pkgs;
        };
        cuda = import ../shells/cuda.nix {
          inherit pkgs cudaPkgs;
        };
        quantum = import ../shells/quantum.nix {
          inherit pkgs;
        };
        quantum-gpu = import ../shells/quantum-gpu.nix {
          inherit pkgs;
          qiskitAerGpu = config.packages.qiskit-aer-gpu;
        };
        systems = import ../shells/systems.nix {
          inherit pkgs;
        };
        containers = import ../shells/containers.nix {
          inherit pkgs;
        };
        virtualization = import ../shells/virtualization.nix {
          inherit pkgs;
        };
        kubernetes = import ../shells/kubernetes.nix {
          inherit pkgs;
        };
        qml = import ../shells/qml.nix {
          inherit pkgs cudaPkgs;
          qiskitMachineLearning = config.packages.qiskit-machine-learning;
        };
        dbms = import ../shells/dbms.nix {
          inherit pkgs;
        };
      };
   };
}
