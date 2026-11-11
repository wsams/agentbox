#!/usr/bin/env bash
# sops + age into ~/.local/bin (MPL-2.0 / BSD). Vault is a separate wrapper.
set -euo pipefail
# shellcheck source=/usr/local/lib/agentbox/lib/user-install.sh
source /usr/local/lib/agentbox/lib/user-install.sh
BIN="$(agentbox_user_bin)"
ARCH="$(agentbox_arch)"

SOPS_VERSION="${SOPS_VERSION:-v3.9.4}"
AGE_VERSION="${AGE_VERSION:-v1.2.1}"

agentbox_fetch_bin \
  "https://github.com/getsops/sops/releases/download/${SOPS_VERSION}/sops-${SOPS_VERSION}.linux.${ARCH}" \
  "${BIN}/sops"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "https://github.com/FiloSottile/age/releases/download/${AGE_VERSION}/age-${AGE_VERSION}-linux-${ARCH}.tar.gz" \
  -o "${tmpdir}/age.tgz"
tar -xzf "${tmpdir}/age.tgz" -C "${tmpdir}"
install -m 0755 "${tmpdir}/age/age" "${BIN}/age"
install -m 0755 "${tmpdir}/age/age-keygen" "${BIN}/age-keygen"
echo "Installed sops, age, age-keygen → ${BIN}"
sops --version
age --version
