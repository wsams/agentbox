#!/usr/bin/env bash
# cosign, skopeo, pack — Apache-2.0 (open source).
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64; PACK_ARCH=linux ;;
  aarch64|arm64) BIN_ARCH=arm64; PACK_ARCH=linux-arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

apt-get update
apt-get install -y --no-install-recommends skopeo
apt-get clean
rm -rf /var/lib/apt/lists/*

COSIGN_VERSION="${COSIGN_VERSION:-v2.4.1}"
curl -fsSL "https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-${BIN_ARCH}" \
  -o /usr/local/bin/cosign
chmod +x /usr/local/bin/cosign

PACK_VERSION="${PACK_VERSION:-v0.36.1}"
curl -fsSL "https://github.com/buildpacks/pack/releases/download/${PACK_VERSION}/pack-${PACK_VERSION}-${PACK_ARCH}.tgz" \
  -o /tmp/pack.tgz
tar -xzf /tmp/pack.tgz -C /usr/local/bin pack
chmod +x /usr/local/bin/pack
rm -f /tmp/pack.tgz
