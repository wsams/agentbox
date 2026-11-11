#!/usr/bin/env bash
set -euo pipefail
source /usr/local/lib/agentbox/lib/user-install.sh
BIN="$(agentbox_user_bin)"
ARCH="$(agentbox_arch)"
RCLONE_VERSION="${RCLONE_VERSION:-v1.68.2}"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip" \
  -o "${tmpdir}/rclone.zip"
unzip -q "${tmpdir}/rclone.zip" -d "${tmpdir}"
install -m 0755 "${tmpdir}/rclone-${RCLONE_VERSION}-linux-${ARCH}/rclone" "${BIN}/rclone"
echo "Installed rclone → ${BIN}"
rclone version
