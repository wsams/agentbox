#!/usr/bin/env bash
# Flux CD CLI (Apache-2.0). Argo CD is a separate feature group.
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64 ;;
  aarch64|arm64) BIN_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

FLUX_VERSION="${FLUX_VERSION:-v2.4.0}"
curl -fsSL "https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/flux.tgz
tar -xzf /tmp/flux.tgz -C /usr/local/bin flux
chmod +x /usr/local/bin/flux
rm -f /tmp/flux.tgz
