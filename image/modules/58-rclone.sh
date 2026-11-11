#!/usr/bin/env bash
# rclone (MIT).
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) RCLONE_ARCH=amd64 ;;
  aarch64|arm64) RCLONE_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

RCLONE_VERSION="${RCLONE_VERSION:-v1.68.2}"
curl -fsSL "https://downloads.rclone.org/${RCLONE_VERSION}/rclone-${RCLONE_VERSION}-linux-${RCLONE_ARCH}.zip" \
  -o /tmp/rclone.zip
unzip -q /tmp/rclone.zip -d /tmp
install -m 0755 "/tmp/rclone-${RCLONE_VERSION}-linux-${RCLONE_ARCH}/rclone" /usr/local/bin/rclone
rm -rf /tmp/rclone.zip "/tmp/rclone-${RCLONE_VERSION}-linux-${RCLONE_ARCH}"
