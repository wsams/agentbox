#!/usr/bin/env bash
# sops (MPL-2.0) + age (BSD) — open source. Vault CLI is BSL → runtime wrapper only.
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64 ;;
  aarch64|arm64) BIN_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

SOPS_VERSION="${SOPS_VERSION:-v3.9.4}"
curl -fsSL "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${BIN_ARCH}" \
  -o /usr/local/bin/sops
chmod +x /usr/local/bin/sops

AGE_VERSION="${AGE_VERSION:-v1.2.1}"
curl -fsSL "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${BIN_ARCH}.tar.gz" \
  -o /tmp/age.tgz
tar -xzf /tmp/age.tgz -C /tmp
install -m 0755 /tmp/age/age /usr/local/bin/age
install -m 0755 /tmp/age/age-keygen /usr/local/bin/age-keygen
rm -rf /tmp/age /tmp/age.tgz
