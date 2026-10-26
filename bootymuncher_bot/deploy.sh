#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

helm upgrade --install bootymuncher-bot ../bootymuncher_bot \
  --namespace discord-bot \
  --create-namespace \
  --values values.yml \
  --values values.local.yml \
  --rollback-on-failure --timeout 10m
