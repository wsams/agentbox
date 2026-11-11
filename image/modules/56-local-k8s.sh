#!/usr/bin/env bash
# kind (Apache-2.0) + k3d (MIT) — need a Docker socket at runtime to create clusters.
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64 ;;
  aarch64|arm64) BIN_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

KIND_VERSION="${KIND_VERSION:-v0.26.0}"
curl -fsSL "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${BIN_ARCH}" \
  -o /usr/local/bin/kind
chmod +x /usr/local/bin/kind

K3D_VERSION="${K3D_VERSION:-v5.7.5}"
curl -fsSL "https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-${BIN_ARCH}" \
  -o /usr/local/bin/k3d
chmod +x /usr/local/bin/k3d
