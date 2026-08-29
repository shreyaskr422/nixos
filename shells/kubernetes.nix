{ pkgs, ... }:

pkgs.mkShell {
  packages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
    kind
    kubectx
    kubelogin
    kustomize

    jq
    yq
    curl
    wget
  ];

  shellHook = ''
    export DEV_SHELL=kubernetes
    echo "Kubernetes development environment"

    ${import ../flake/devshell-common.nix { inherit pkgs; }}
  '';
}
