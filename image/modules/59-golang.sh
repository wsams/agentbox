#!/usr/bin/env bash
# Go toolchain (BSD-style license from go.dev).
set -euo pipefail
ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) GO_ARCH=amd64 ;;
  aarch64|arm64) GO_ARCH=arm64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

GO_VERSION="${GO_VERSION:-1.23.4}"
curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -o /tmp/go.tgz
rm -rf /usr/local/go
tar -C /usr/local -xzf /tmp/go.tgz
rm -f /tmp/go.tgz
ln -sfn /usr/local/go/bin/go /usr/local/bin/go
ln -sfn /usr/local/go/bin/gofmt /usr/local/bin/gofmt
echo 'export PATH="/usr/local/go/bin:$PATH"' >/etc/profile.d/golang.sh
