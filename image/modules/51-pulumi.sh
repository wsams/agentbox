#!/usr/bin/env bash
set -euo pipefail
curl -fsSL https://get.pulumi.com | sh
# Install into a shared location
if [[ -d /root/.pulumi/bin ]]; then
  install -m 0755 /root/.pulumi/bin/* /usr/local/bin/ 2>/dev/null || \
    cp -a /root/.pulumi/bin/. /usr/local/bin/
fi
# Language hosts for Node/Python are already present; crd2pulumi optional
CRD2PULUMI_VERSION="${CRD2PULUMI_VERSION:-v1.5.3}"
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) C2P_ARCH=amd64 ;;
  aarch64|arm64) C2P_ARCH=arm64 ;;
esac
curl -fsSL "https://github.com/pulumi/crd2pulumi/releases/download/${CRD2PULUMI_VERSION}/crd2pulumi-${CRD2PULUMI_VERSION}-linux-${C2P_ARCH}.tar.gz" \
  -o /tmp/crd2pulumi.tgz || true
if [[ -s /tmp/crd2pulumi.tgz ]]; then
  tar -xzf /tmp/crd2pulumi.tgz -C /usr/local/bin
  chmod +x /usr/local/bin/crd2pulumi || true
  rm -f /tmp/crd2pulumi.tgz
fi
