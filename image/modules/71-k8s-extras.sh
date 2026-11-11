#!/usr/bin/env bash
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64 ;;
  aarch64|arm64) BIN_ARCH=arm64 ;;
esac

KUSTOMIZE_VERSION="${KUSTOMIZE_VERSION:-v5.4.3}"
curl -fsSL "https://github.com/kubernetes-sigs/kustomize/releases/download/kustomize%2F${KUSTOMIZE_VERSION}/kustomize_${KUSTOMIZE_VERSION}_linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/kustomize.tgz
tar -xzf /tmp/kustomize.tgz -C /usr/local/bin kustomize
chmod +x /usr/local/bin/kustomize
rm -f /tmp/kustomize.tgz

KUBECONFORM_VERSION="${KUBECONFORM_VERSION:-v0.6.7}"
curl -fsSL "https://github.com/yannh/kubeconform/releases/download/${KUBECONFORM_VERSION}/kubeconform-linux-${BIN_ARCH}.tar.gz" \
  -o /tmp/kubeconform.tgz
tar -xzf /tmp/kubeconform.tgz -C /usr/local/bin kubeconform
chmod +x /usr/local/bin/kubeconform
rm -f /tmp/kubeconform.tgz

KUBELINTER_VERSION="${KUBELINTER_VERSION:-v0.6.8}"
curl -fsSL "https://github.com/stackrox/kube-linter/releases/download/${KUBELINTER_VERSION}/kube-linter-linux_${BIN_ARCH}" \
  -o /usr/local/bin/kube-linter || \
curl -fsSL "https://github.com/stackrox/kube-linter/releases/download/${KUBELINTER_VERSION}/kube-linter-linux" \
  -o /usr/local/bin/kube-linter
chmod +x /usr/local/bin/kube-linter

# kubectl-neat via krew-less direct install
NEAT_VERSION="${NEAT_VERSION:-v2.0.4}"
curl -fsSL "https://github.com/itaysk/kubectl-neat/releases/download/${NEAT_VERSION}/kubectl-neat_linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/neat.tgz || true
if [[ -s /tmp/neat.tgz ]]; then
  tar -xzf /tmp/neat.tgz -C /usr/local/bin
  chmod +x /usr/local/bin/kubectl-neat || true
  rm -f /tmp/neat.tgz
fi
