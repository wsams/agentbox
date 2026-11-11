#!/usr/bin/env bash
# Extra network diagnostics beyond the base image.
set -euo pipefail
# Most network tools are already in 00-base. This group adds grpcurl.
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) ARCH=x86_64 ;;
  aarch64|arm64) ARCH=arm64 ;;
esac
GRPCURL_VERSION="${GRPCURL_VERSION:-1.9.1}"
curl -fsSL "https://github.com/fullstorydev/grpcurl/releases/download/v${GRPCURL_VERSION}/grpcurl_${GRPCURL_VERSION}_linux_${ARCH}.tar.gz" \
  -o /tmp/grpcurl.tgz
tar -xzf /tmp/grpcurl.tgz -C /usr/local/bin grpcurl
chmod +x /usr/local/bin/grpcurl
rm -f /tmp/grpcurl.tgz
