#!/usr/bin/env bash
set -euo pipefail
source /usr/local/lib/agentbox/lib/user-install.sh
BIN="$(agentbox_user_bin)"
ARCH="$(agentbox_arch)"
FLUX_VERSION="${FLUX_VERSION:-v2.4.0}"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "https://github.com/fluxcd/flux2/releases/download/${FLUX_VERSION}/flux_${FLUX_VERSION#v}_linux_${ARCH}.tar.gz" \
  -o "${tmpdir}/flux.tgz"
tar -xzf "${tmpdir}/flux.tgz" -C "${BIN}" flux
chmod +x "${BIN}/flux"
echo "Installed flux → ${BIN}"
flux version --client || flux --version || true
