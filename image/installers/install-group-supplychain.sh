#!/usr/bin/env bash
# cosign + pack into ~/.local/bin. skopeo usually needs apt (root); skip with a note if missing.
set -euo pipefail
source /usr/local/lib/agentbox/lib/user-install.sh
BIN="$(agentbox_user_bin)"
ARCH="$(agentbox_arch)"
case "${ARCH}" in
  amd64) PACK_ARCH=linux ;;
  arm64) PACK_ARCH=linux-arm64 ;;
esac

COSIGN_VERSION="${COSIGN_VERSION:-v2.4.1}"
PACK_VERSION="${PACK_VERSION:-v0.36.1}"

agentbox_fetch_bin \
  "https://github.com/sigstore/cosign/releases/download/${COSIGN_VERSION}/cosign-linux-${ARCH}" \
  "${BIN}/cosign"

tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "https://github.com/buildpacks/pack/releases/download/${PACK_VERSION}/pack-${PACK_VERSION}-${PACK_ARCH}.tgz" \
  -o "${tmpdir}/pack.tgz"
tar -xzf "${tmpdir}/pack.tgz" -C "${BIN}" pack
chmod +x "${BIN}/pack"

if command -v skopeo >/dev/null 2>&1; then
  echo "skopeo already present: $(command -v skopeo)"
else
  echo "Note: skopeo is not installed (needs apt/root). Use a flavor with the supplychain group, or: sudo apt-get install skopeo"
fi
echo "Installed cosign, pack → ${BIN}"
cosign version
pack version
