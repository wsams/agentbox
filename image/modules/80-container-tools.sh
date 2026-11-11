#!/usr/bin/env bash
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64; CRANE_ARCH=x86_64 ;;
  aarch64|arm64) BIN_ARCH=arm64; CRANE_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

DIVE_VERSION="${DIVE_VERSION:-0.12.0}"
curl -fsSL "https://github.com/wagoodman/dive/releases/download/v${DIVE_VERSION}/dive_${DIVE_VERSION}_linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/dive.tgz
tar -xzf /tmp/dive.tgz -C /usr/local/bin dive
chmod +x /usr/local/bin/dive
rm -f /tmp/dive.tgz

# Asset arch is x86_64 / arm64 (not amd64)
CRANE_VERSION="${CRANE_VERSION:-v0.22.1}"
curl -fsSL "https://github.com/google/go-containerregistry/releases/download/${CRANE_VERSION}/go-containerregistry_Linux_${CRANE_ARCH}.tar.gz" \
  -o /tmp/crane.tgz
tar -xzf /tmp/crane.tgz -C /usr/local/bin crane
chmod +x /usr/local/bin/crane
rm -f /tmp/crane.tgz
