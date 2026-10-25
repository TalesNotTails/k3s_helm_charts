#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
VERSION="$(cat VERSION)"

helm repo add open-webui https://helm.openwebui.com/ --force-update >/dev/null
helm repo update open-webui >/dev/null

helm upgrade --install open-webui open-webui/open-webui \
  --version "$VERSION" \
  --namespace open-webui \
  --create-namespace \
  --values values.yml \
  --rollback-on-failure --timeout 10m

kubectl apply -f tailscale-ingress.yml
kubectl apply -f ollama-egress.yml
