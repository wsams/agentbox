#!/usr/bin/env bash
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64 ;;
  aarch64|arm64) BIN_ARCH=arm64 ;;
esac
ARGOCD_VERSION="${ARGOCD_VERSION:-v2.12.6}"
curl -fsSL "https://github.com/argoproj/argo-cd/releases/download/${ARGOCD_VERSION}/argocd-linux-${BIN_ARCH}" \
  -o /usr/local/bin/argocd
chmod +x /usr/local/bin/argocd
