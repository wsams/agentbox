#!/usr/bin/env bash
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64; TRIVY_ARCH=64bit; GITLEAKS_ARCH=x64 ;;
  aarch64|arm64) BIN_ARCH=arm64; TRIVY_ARCH=ARM64; GITLEAKS_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

TRIVY_VERSION="${TRIVY_VERSION:-0.76.2}"
curl -fsSL "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${TRIVY_ARCH}.tar.gz" \
  -o /tmp/trivy.tgz
tar -xzf /tmp/trivy.tgz -C /usr/local/bin trivy
chmod +x /usr/local/bin/trivy
rm -f /tmp/trivy.tgz

# gitleaks asset arch is x64 (not amd64) on linux
GITLEAKS_VERSION="${GITLEAKS_VERSION:-8.30.1}"
curl -fsSL "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${GITLEAKS_ARCH}.tar.gz" \
  -o /tmp/gitleaks.tgz
tar -xzf /tmp/gitleaks.tgz -C /usr/local/bin gitleaks
chmod +x /usr/local/bin/gitleaks
rm -f /tmp/gitleaks.tgz

SYFT_VERSION="${SYFT_VERSION:-v1.57.1}"
curl -fsSL "https://github.com/anchore/syft/releases/download/${SYFT_VERSION}/syft_${SYFT_VERSION#v}_linux_${BIN_ARCH}.tar.gz" \
  -o /tmp/syft.tgz
tar -xzf /tmp/syft.tgz -C /usr/local/bin syft
chmod +x /usr/local/bin/syft
rm -f /tmp/syft.tgz
