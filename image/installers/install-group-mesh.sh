#!/usr/bin/env bash
set -euo pipefail
source /usr/local/lib/agentbox/lib/user-install.sh
BIN="$(agentbox_user_bin)"
ARCH="$(agentbox_arch)"
CILIUM_VERSION="${CILIUM_VERSION:-v0.16.23}"
HUBBLE_VERSION="${HUBBLE_VERSION:-v1.16.3}"
ISTIO_VERSION="${ISTIO_VERSION:-1.24.2}"
LINKERD_VERSION="${LINKERD_VERSION:-stable-2.14.10}"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT

curl -fsSL "https://github.com/cilium/cilium-cli/releases/download/${CILIUM_VERSION}/cilium-linux-${ARCH}.tar.gz" -o "${tmpdir}/cilium.tgz"
tar -xzf "${tmpdir}/cilium.tgz" -C "${BIN}" cilium
curl -fsSL "https://github.com/cilium/hubble/releases/download/${HUBBLE_VERSION}/hubble-linux-${ARCH}.tar.gz" -o "${tmpdir}/hubble.tgz"
tar -xzf "${tmpdir}/hubble.tgz" -C "${BIN}" hubble
curl -fsSL "https://github.com/istio/istio/releases/download/${ISTIO_VERSION}/istioctl-${ISTIO_VERSION}-linux-${ARCH}.tar.gz" -o "${tmpdir}/istio.tgz"
tar -xzf "${tmpdir}/istio.tgz" -C "${tmpdir}"
install -m 0755 "${tmpdir}/istioctl" "${BIN}/istioctl"
agentbox_fetch_bin \
  "https://github.com/linkerd/linkerd2/releases/download/${LINKERD_VERSION}/linkerd2-cli-${LINKERD_VERSION}-linux-${ARCH}" \
  "${BIN}/linkerd"
chmod +x "${BIN}/cilium" "${BIN}/hubble"
echo "Installed cilium, hubble, istioctl, linkerd → ${BIN}"
