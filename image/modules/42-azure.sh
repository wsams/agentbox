#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
  | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
  >/etc/apt/sources.list.d/azure-cli.list
apt-get update
apt-get install -y --no-install-recommends azure-cli
apt-get clean
rm -rf /var/lib/apt/lists/*
