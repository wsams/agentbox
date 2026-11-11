#!/usr/bin/env bash
# Kubernetes tooling (vendor-neutral). No Tanzu / vSphere plugins.
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64; KX_ARCH=x86_64 ;;
  aarch64|arm64) BIN_ARCH=arm64; KX_ARCH=arm64 ;;
esac

KUBECTL_VERSION="${KUBECTL_VERSION:-v1.31.2}"
curl -fsSL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${BIN_ARCH}/kubectl" \
  -o /usr/local/bin/kubectl
chmod +x /usr/local/bin/kubectl

HELM_VERSION="${HELM_VERSION:-v3.16.2}"
curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${BIN_ARCH}.tar.gz" -o /tmp/helm.tgz
tar -xzf /tmp/helm.tgz -C /tmp
install -m 0755 "/tmp/linux-${BIN_ARCH}/helm" /usr/local/bin/helm
rm -rf /tmp/helm.tgz "/tmp/linux-${BIN_ARCH}"
# No helm repo add — operators configure their own charts.

K9S_VERSION="${K9S_VERSION:-v0.32.5}"
curl -fsSL "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/k9s.tgz
tar -xzf /tmp/k9s.tgz -C /usr/local/bin k9s
chmod +x /usr/local/bin/k9s
rm -f /tmp/k9s.tgz

STERN_VERSION="${STERN_VERSION:-1.31.0}"
curl -fsSL "https://github.com/stern/stern/releases/download/v${STERN_VERSION}/stern_${STERN_VERSION}_linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/stern.tgz
tar -xzf /tmp/stern.tgz -C /usr/local/bin stern
chmod +x /usr/local/bin/stern
rm -f /tmp/stern.tgz

KUBECTX_VERSION="${KUBECTX_VERSION:-v0.9.5}"
curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_${KX_ARCH}.tar.gz" \
  -o /tmp/kubectx.tgz
curl -fsSL "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubens_${KUBECTX_VERSION}_linux_${KX_ARCH}.tar.gz" \
  -o /tmp/kubens.tgz
tar -xzf /tmp/kubectx.tgz -C /usr/local/bin kubectx
tar -xzf /tmp/kubens.tgz -C /usr/local/bin kubens
chmod +x /usr/local/bin/kubectx /usr/local/bin/kubens
rm -f /tmp/kubectx.tgz /tmp/kubens.tgz

helm plugin install https://github.com/databus23/helm-diff || true
