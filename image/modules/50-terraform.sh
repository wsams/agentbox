#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
ARCH="$(dpkg --print-architecture)"

curl -fsSL https://apt.releases.hashicorp.com/gpg \
  | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(. /etc/os-release && echo "$VERSION_CODENAME") main" \
  >/etc/apt/sources.list.d/hashicorp.list
apt-get update
apt-get install -y --no-install-recommends terraform
apt-get clean
rm -rf /var/lib/apt/lists/*

TFLINT_VERSION="${TFLINT_VERSION:-v0.53.0}"
case "${ARCH}" in
  amd64) TF_ARCH=amd64 ;;
  arm64) TF_ARCH=arm64 ;;
esac
curl -fsSL "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_${TF_ARCH}.zip" -o /tmp/tflint.zip
unzip -q /tmp/tflint.zip -d /usr/local/bin
chmod +x /usr/local/bin/tflint
rm -f /tmp/tflint.zip

TFDOCS_VERSION="${TFDOCS_VERSION:-v0.19.0}"
curl -fsSL "https://github.com/terraform-docs/terraform-docs/releases/download/${TFDOCS_VERSION}/terraform-docs-${TFDOCS_VERSION}-linux-${TF_ARCH}.tar.gz" \
  -o /tmp/tfdocs.tgz
tar -xzf /tmp/tfdocs.tgz -C /usr/local/bin terraform-docs
chmod +x /usr/local/bin/terraform-docs
rm -f /tmp/tfdocs.tgz
