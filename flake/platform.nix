{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:

    let
      platformVerify = pkgs.writeShellApplication {
        name = "platform-verify";

        runtimeInputs = with pkgs; [
          nix
        ];

        text = ''
          set -euo pipefail

          echo "==> Platform verification"

          echo
          nix run .#check-fast

          echo
          echo "==> Kubernetes verification"

          nix run .#kubernetes-verify

          echo
          echo "================================"
          echo " PLATFORM HEALTH: OK"
          echo "================================"
        '';
      };
    in
    {
      packages.platform-verify = platformVerify;
    };
}
