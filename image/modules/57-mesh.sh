#!/usr/bin/env bash
# cilium + hubble + istioctl + linkerd — Apache-2.0.
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64 ;;
  aarch64|arm64) BIN_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

CILIUM_VERSION="${CILIUM_VERSION:-v0.16.23}"
curl -fsSL "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_VERSION}/cilium-linux-${BIN_ARCH}.tar.gz" \
  -o /tmp/cilium.tgz
tar -xzf /tmp/cilium.tgz -C /usr/local/bin cilium
chmod +x /usr/local/bin/cilium
rm -f /tmp/cilium.tgz

HUBBLE_VERSION="${HUBBLE_VERSION:-v1.16.3}"
curl -fsSL "https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-${BIN_ARCH}.tar.gz" \
  -o /tmp/hubble.tgz
tar -xzf /tmp/hubble.tgz -C /usr/local/bin hubble
chmod +x /usr/local/bin/hubble
rm -f /tmp/hubble.tgz

ISTIO_VERSION="${ISTIO_VERSION:-1.24.2}"
curl -fsSL "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istioctl-${ISTIO_VERSION}-linux-${BIN_ARCH}.tar.gz" \
  -o /tmp/istio.tgz
tar -xzf /tmp/istio.tgz -C /tmp
install -m 0755 /tmp/istioctl /usr/local/bin/istioctl
rm -rf /tmp/istio.tgz /tmp/istioctl

LINKERD_VERSION="${LINKERD_VERSION:-stable-2.14.10}"
curl -fsSL "https://github.com/linkerd/linkerd2/releases/download/${LINKERD_VERSION}/linkerd2-cli-${LINKERD_VERSION}-linux-${BIN_ARCH}" \
  -o /usr/local/bin/linkerd
chmod +x /usr/local/bin/linkerd
