#!/usr/bin/env bash
# Install Go under ~/.local/go (BSD-style license).
set -euo pipefail
source /usr/local/lib/agentbox/lib/user-install.sh
ARCH="$(agentbox_arch)"
GO_VERSION="${GO_VERSION:-1.23.4}"
prefix="${HOME}/.local"
mkdir -p "${prefix}"
tmpdir="$(mktemp -d)"
trap 'rm -rf "${tmpdir}"' EXIT
curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH}.tar.gz" -o "${tmpdir}/go.tgz"
rm -rf "${prefix}/go"
tar -C "${prefix}" -xzf "${tmpdir}/go.tgz"
mkdir -p "${HOME}/.local/bin"
ln -sfn "${prefix}/go/bin/go" "${HOME}/.local/bin/go"
ln -sfn "${prefix}/go/bin/gofmt" "${HOME}/.local/bin/gofmt"
echo "Installed Go ${GO_VERSION} → ${prefix}/go (symlinked in ~/.local/bin)"
go version
