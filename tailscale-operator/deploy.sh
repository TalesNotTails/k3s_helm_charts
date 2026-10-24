#!/usr/bin/env bash
# tailscale-operator/deploy.sh
set -euo pipefail

cd "$(dirname "$0")"
VERSION="$(cat VERSION)"

helm repo add tailscale https://pkgs.tailscale.com/helmcharts --force-update >/dev/null
helm repo update tailscale >/dev/null

helm upgrade --install tailscale-operator tailscale/tailscale-operator \
  --version "$VERSION" \
  --namespace tailscale \
  --create-namespace \
  --values values.yml \
  --atomic \
  --timeout 5m
