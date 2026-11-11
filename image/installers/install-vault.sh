#!/usr/bin/env bash
# HashiCorp Vault CLI — Business Source License 1.1 (not OSI open source).
# Not baked into published images; fetched on demand into ~/.local/bin.
set -euo pipefail

echo "Installing Vault CLI into ~/.local/bin…"
echo "License: Business Source License 1.1 — https://www.hashicorp.com/license-faq"
echo "You are downloading this for your own use under HashiCorp's terms."

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) VAULT_ARCH=amd64 ;;
  aarch64|arm64) VAULT_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

VAULT_VERSION="${VAULT_VERSION:-1.18.3}"
mkdir -p "${HOME}/.local/bin"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${VAULT_ARCH}.zip" \
  -o "${tmpdir}/vault.zip"
unzip -q "${tmpdir}/vault.zip" -d "${tmpdir}"
install -m 0755 "${tmpdir}/vault" "${HOME}/.local/bin/vault"
echo "Installed: ${HOME}/.local/bin/vault"
"${HOME}/.local/bin/vault" version
