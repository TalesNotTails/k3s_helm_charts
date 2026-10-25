#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

helm upgrade --install searxng ../searxng \
  --namespace open-webui \
  --values values.yml \
  --rollback-on-failure --timeout 10m

