{ inputs, ... }:

{
  perSystem =
    { pkgs, system, cudaPkgs, ... }:

    let
      qiskitAerGpu =
        import ../packages/quantum/qiskit-aer-gpu.nix {
          inherit pkgs cudaPkgs;
        };

      qiskitMachineLearning =
        import ../packages/quantum/qiskit-machine-learning.nix {
          inherit pkgs;
        };

      qmlPython = cudaPkgs.python313.withPackages (ps: with ps; [
        jax
        jaxlib
        jax-cuda12-plugin
        jax-cuda12-pjrt

        qiskit
        qiskit-aer
        numpy
        scipy
        scikit-learn
        matplotlib
      ]);

      qmlTest = pkgs.runCommand "check-qml-environment"
        {
          nativeBuildInputs = [ qmlPython ];
        }
        ''
          python3 - <<'PY'
          import jax
          import qiskit
          import qiskit_aer
          import sklearn

          print("JAX:", jax.__version__)
          print("Qiskit:", qiskit.__version__)
          print("Aer:", qiskit_aer.__version__)
          print("scikit-learn:", sklearn.__version__)
          print("QML imports: OK")
          PY

          touch "$out"
        '';

      quantumGpuTest = pkgs.runCommand "check-qiskit-aer-gpu"
        {
          nativeBuildInputs = [
            pkgs.python313
            pkgs.python313Packages.qiskit
            qiskitAerGpu
          ];
        }
        ''
          python3 - <<'PY'
          from qiskit_aer import AerSimulator

          sim = AerSimulator()

          assert "GPU" in sim.available_devices(), \
            f"GPU unavailable: {sim.available_devices()}"

          gpu = AerSimulator(
              method="statevector",
              device="GPU"
          )

          assert gpu.options.device == "GPU"

          print("Available devices:", sim.available_devices())
          print("GPU device:", gpu.options.device)
          PY

          touch "$out"
        '';

      qiskitMlTest = pkgs.runCommand "check-qiskit-machine-learning"
        {
          nativeBuildInputs = [
            pkgs.python313
            pkgs.python313Packages.qiskit
            pkgs.python313Packages.scikit-learn
            qiskitMachineLearning
          ];
        }
        ''
          python3 - <<'PY'
          import qiskit
          import qiskit_machine_learning

          from qiskit_machine_learning.algorithms import (
              NeuralNetworkClassifier,
          )

          print("Qiskit:", qiskit.__version__)
          print("Qiskit ML:", qiskit_machine_learning.__version__)
          print("QML import: OK")
          print("NeuralNetworkClassifier:", NeuralNetworkClassifier)
          PY

          touch "$out"
        '';

      nixosLayout = pkgs.runCommand "check-nixos-layout" { } ''
        test -f ${../hosts/SoS/default.nix}
        test -f ${../hosts/SoS/hardware-configuration.nix}

        test -f ${../modules/core/nix.nix}
        test -f ${../modules/core/boot.nix}
        test -f ${../modules/core/users.nix}

        test -f ${../modules/hardware/asus.nix}
        test -f ${../modules/hardware/graphics.nix}
        test -f ${../modules/hardware/power.nix}

        test -f ${../modules/networking.nix}
        test -f ${../modules/desktop/desktop.nix}
        test -f ${../modules/desktop/ly.nix}

        test -f ${../modules/containers/containers.nix}
        test -f ${../modules/virtualization/virtualization.nix}

        test -f ${../modules/audio.nix}
        test -f ${../modules/services.nix}
        test -f ${../modules/packages.nix}
        test -f ${../modules/fonts.nix}

        test -f ${../home/home.nix}
        test -f ${../home/modules/packages.nix}

        touch "$out"
      '';

      cudaTest = pkgs.runCommand "check-cuda-toolchain"
        {
          nativeBuildInputs = [
            cudaPkgs.cudaPackages.cuda_nvcc
            cudaPkgs.cudaPackages.cuda_cudart
          ];
        }
        ''
          nvcc --version
          test "$(command -v nvcc)" != ""

          test -f "${cudaPkgs.cudaPackages.cuda_cudart}/include/cuda_runtime.h"

          cat > hello.cu <<'EOF'
          #include <cuda_runtime.h>

          __global__ void hello() {}

          int main() {
            return 0;
          }
          EOF

          nvcc \
            -I"${cudaPkgs.cudaPackages.cuda_cudart}/include" \
            -c hello.cu \
            -o hello.o

          test -f hello.o

          touch "$out"
        '';

    in
    {
      checks = {
        qml = qmlTest;
        quantum-gpu = quantumGpuTest;
        qiskit-machine-learning = qiskitMlTest;
        nixos-layout = nixosLayout;
        cuda = cudaTest;
      };

      packages.check-fast = pkgs.writeShellApplication {
        name = "check-fast";

        runtimeInputs = with pkgs; [
          nix
        ];

        text = ''
          set -euo pipefail

          echo "==> Fast flake checks"

          nix build .#checks.x86_64-linux.nixos-layout
          nix build .#checks.x86_64-linux.kubernetes

          echo
          echo "==> Fast checks passed"
        '';
      };
    };
}
