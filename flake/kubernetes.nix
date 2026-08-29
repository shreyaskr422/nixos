{ inputs, ... }:

{
  perSystem =
    { pkgs, ... }:

    let
      kubernetesCheck = pkgs.runCommand "check-kubernetes-layout" { } ''
        test -d ${../kubernetes}

        test -f ${../kubernetes/cluster/kind.yaml}

        test -d ${../kubernetes/apps/nginx}
        test -f ${../kubernetes/apps/nginx/base/kustomization.yaml}
        test -f ${../kubernetes/apps/nginx/base/deployment.yaml}
        test -f ${../kubernetes/apps/nginx/base/service.yaml}
        test -f ${../kubernetes/apps/nginx/base/ingress.yaml}
        test -f ${../kubernetes/apps/nginx/overlays/dev/kustomization.yaml}

        test -f ${../kubernetes/platform/traefik/values.yaml}
        test -f ${../kubernetes/platform/monitoring/values.yaml}

        touch "$out"
      '';

      kubernetesVerify = pkgs.writeShellApplication {
        name = "kubernetes-verify";

        runtimeInputs = with pkgs; [
          kind
          kubectl
          kubernetes-helm
          curl
        ];

        text = ''
          set -euo pipefail

          CLUSTER_NAME="sos"

          echo "==> Verifying Kubernetes platform"

          if ! kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
            echo "ERROR: Kind cluster '$CLUSTER_NAME' does not exist"
            exit 1
          fi

          kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null

          echo
          echo "==> Kubernetes API"

          kubectl get --raw='/readyz' >/dev/null
          echo "Kubernetes API: OK"

          echo
          echo "==> Node"

          kubectl wait \
            --for=condition=Ready \
            node/sos-control-plane \
            --timeout=30s

          echo "Node: OK"

          echo
          echo "==> Traefik"

          kubectl rollout status \
            deployment/traefik \
            -n traefik \
            --timeout=60s

          echo "Traefik: OK"

          echo
          echo "==> Nginx"

          kubectl rollout status \
            deployment/nginx \
            -n default \
            --timeout=60s

          echo "Nginx: OK"

          echo
          echo "==> Monitoring"

          kubectl rollout status \
            deployment/monitoring-grafana \
            -n monitoring \
            --timeout=60s

          kubectl rollout status \
            deployment/monitoring-kube-prometheus-operator \
            -n monitoring \
            --timeout=60s

          kubectl rollout status \
            deployment/monitoring-kube-state-metrics \
            -n monitoring \
            --timeout=60s

          kubectl rollout status \
            daemonset/monitoring-prometheus-node-exporter \
            -n monitoring \
            --timeout=60s

          kubectl rollout status \
            statefulset/alertmanager-monitoring-kube-prometheus-alertmanager \
            -n monitoring \
            --timeout=60s

          kubectl rollout status \
            statefulset/prometheus-monitoring-kube-prometheus-prometheus \
            -n monitoring \
            --timeout=60s

          echo "Monitoring: OK"

          echo
          echo "==> Helm releases"

          helm list -A

          echo
          echo "==> HTTPS ingress"

          PORT_FORWARD_LOG="$(mktemp)"
          PORT_FORWARD_PID=""

          cleanup() {
            if [ -n "''${PORT_FORWARD_PID:-}" ]; then
              kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
            fi

            rm -f "$PORT_FORWARD_LOG"
          }

          trap cleanup EXIT

          kubectl -n traefik port-forward svc/traefik 8443:443 \
            >"$PORT_FORWARD_LOG" 2>&1 &

          PORT_FORWARD_PID=$!

          ingress_ok="false"

          for _ in $(seq 1 30); do
            if curl \
              -k \
              --silent \
              --resolve nginx.local:8443:127.0.0.1 \
              --output /dev/null \
              --write-out '%{http_code}' \
              https://nginx.local:8443/ \
              | grep -qx '200'
            then
              ingress_ok="true"
              break
            fi

            sleep 1
          done

          if [ "$ingress_ok" != "true" ]; then
            echo "ERROR: HTTPS ingress check failed"
            cat "$PORT_FORWARD_LOG"
            exit 1
          fi

          echo "HTTPS ingress: OK (HTTP 200)"

          echo
          echo "==> Platform healthy"
        '';
      };

      kubernetesReset = pkgs.writeShellApplication {
        name = "kubernetes-reset";

        runtimeInputs = with pkgs; [
          kind
        ];

        text = ''
          set -euo pipefail

          CLUSTER_NAME="sos"

          echo "==> Kubernetes reset"

          if kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; then
            echo "Deleting Kind cluster: $CLUSTER_NAME"

            kind delete cluster \
              --name "$CLUSTER_NAME"

            echo "Cluster deleted"
          else
            echo "Cluster '$CLUSTER_NAME' does not exist"
          fi
        '';
      };

      kubernetesBootstrap = pkgs.writeShellApplication {
        name = "kubernetes-bootstrap";

        runtimeInputs = with pkgs; [
          kind
          kubectl
          kubernetes-helm
          kustomize
          curl
          openssl
          systemd
        ];

        text = ''
          set -euo pipefail

          export KIND_EXPERIMENTAL_PROVIDER="podman"

          CLUSTER_NAME="sos"
          ROOT="${../kubernetes}"

          echo "==> Checking Kubernetes tooling"
          kind version
          kubectl version --client
          helm version --short
          kustomize version

          echo
          echo "==> Ensuring Kind cluster exists"

          if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
            echo "Cluster '$CLUSTER_NAME' does not exist"
          else
            echo "Cluster '$CLUSTER_NAME' already exists"
          fi

          kubectl config use-context "kind-$CLUSTER_NAME" \
            >/dev/null 2>&1 || true

          if ! kubectl get --raw='/readyz' >/dev/null 2>&1; then
            echo "Existing cluster is unreachable; recreating it"

            if kind get clusters | grep -qx "$CLUSTER_NAME"; then
              kind delete cluster --name "$CLUSTER_NAME"
            fi

            systemd-run --scope --user -p Delegate=yes \
              kind create cluster \
              --name "$CLUSTER_NAME" \
              --config "$ROOT/cluster/kind.yaml"

            kubectl config use-context "kind-$CLUSTER_NAME" >/dev/null
          fi

          echo
          echo "==> Waiting for Kubernetes API"

          until kubectl get --raw='/readyz' >/dev/null 2>&1; do
            sleep 2
          done

          echo "Kubernetes API is ready"

          echo
          echo "==> Waiting for node"

          kubectl wait \
            --for=condition=Ready \
            node/sos-control-plane \
            --timeout=180s

          echo
          echo "==> Installing Traefik"

          helm upgrade --install traefik \
            --repo https://traefik.github.io/charts \
            traefik \
            --version 41.3.0 \
            --namespace traefik \
            --create-namespace \
            -f "$ROOT/platform/traefik/values.yaml"

          kubectl rollout status \
            deployment/traefik \
            -n traefik \
            --timeout=300s

          echo
          echo "==> Creating development TLS certificate"

          TMPDIR="$(mktemp -d)"
          PORT_FORWARD_LOG=""
          PORT_FORWARD_PID=""

          cleanup() {
            if [ -n "''${PORT_FORWARD_PID:-}" ]; then
              kill "$PORT_FORWARD_PID" >/dev/null 2>&1 || true
            fi

            if [ -n "''${PORT_FORWARD_LOG:-}" ]; then
              rm -f "$PORT_FORWARD_LOG"
            fi

            rm -rf "$TMPDIR"
          }

          trap cleanup EXIT

          if ! kubectl get secret nginx-tls >/dev/null 2>&1; then
            openssl req \
              -x509 \
              -nodes \
              -newkey rsa:2048 \
              -keyout "$TMPDIR/nginx.local.key" \
              -out "$TMPDIR/nginx.local.crt" \
              -days 365 \
              -subj "/CN=nginx.local" \
              -addext "subjectAltName=DNS:nginx.local" \
              >/dev/null 2>&1

            kubectl create secret tls nginx-tls \
              --cert="$TMPDIR/nginx.local.crt" \
              --key="$TMPDIR/nginx.local.key"
          else
            echo "Secret 'nginx-tls' already exists"
          fi

          echo
          echo "==> Applying nginx application"

          kubectl apply \
            -k "$ROOT/apps/nginx/overlays/dev"

          kubectl rollout status \
            deployment/nginx \
            --timeout=180s

          echo
          echo "==> Installing monitoring"

          MONITORING_CHART="$HOME/.cache/helm/repository/kube-prometheus-stack-88.5.4.tgz"

          if [ ! -f "$MONITORING_CHART" ]; then
            echo "Monitoring chart is not cached:"
            echo "  $MONITORING_CHART"
            echo
            echo "Run:"
            echo "  nix develop .#kubernetes"
            echo "  helm pull prometheus-community/kube-prometheus-stack --version 88.5.4"
            exit 1
          fi

          helm upgrade --install monitoring \
            "$MONITORING_CHART" \
            --namespace monitoring \
            --create-namespace \
            -f "$ROOT/platform/monitoring/values.yaml"

          echo
          echo "==> Waiting for monitoring"

          kubectl rollout status \
            deployment/monitoring-grafana \
            -n monitoring \
            --timeout=600s

          kubectl rollout status \
            deployment/monitoring-kube-prometheus-operator \
            -n monitoring \
            --timeout=600s

          kubectl rollout status \
            deployment/monitoring-kube-state-metrics \
            -n monitoring \
            --timeout=600s

          kubectl rollout status \
            daemonset/monitoring-prometheus-node-exporter \
            -n monitoring \
            --timeout=600s

          kubectl rollout status \
            statefulset/alertmanager-monitoring-kube-prometheus-alertmanager \
            -n monitoring \
            --timeout=600s

          kubectl rollout status \
            statefulset/prometheus-monitoring-kube-prometheus-prometheus \
            -n monitoring \
            --timeout=600s

          echo
          echo "==> Verifying HTTPS ingress"

          PORT_FORWARD_LOG="$(mktemp)"

          kubectl -n traefik port-forward svc/traefik 8443:443 \
            >"$PORT_FORWARD_LOG" 2>&1 &

          PORT_FORWARD_PID=$!

          ingress_ok="false"

          for _ in $(seq 1 30); do
            if curl \
              -k \
              --silent \
              --resolve nginx.local:8443:127.0.0.1 \
              --output /dev/null \
              --write-out '%{http_code}' \
              https://nginx.local:8443/ \
              | grep -qx '200'
            then
              ingress_ok="true"
              echo "HTTPS ingress check: OK (HTTP 200)"
              break
            fi

            sleep 1
          done

          if [ "$ingress_ok" != "true" ]; then
            echo "ERROR: HTTPS ingress check failed"
            cat "$PORT_FORWARD_LOG"
            exit 1
          fi

          echo
          echo "==> Cluster summary"
          echo

          kubectl get nodes

          echo
          kubectl get pods -A

          echo
          helm list -A

          echo
          echo "==> Kubernetes platform ready"
          echo
          echo "HTTP:"
          echo "  kubectl -n traefik port-forward svc/traefik 8080:80"
          echo
          echo "HTTPS:"
          echo "  kubectl -n traefik port-forward svc/traefik 8443:443"
          echo
          echo "Test:"
          echo "  curl -k --resolve nginx.local:8443:127.0.0.1 https://nginx.local:8443/"
        '';
      };
    in
    {
      checks.kubernetes = kubernetesCheck;

      packages.kubernetes-bootstrap = kubernetesBootstrap;
      packages.kubernetes-verify = kubernetesVerify;
      packages.kubernetes-reset = kubernetesReset;
    };
}
