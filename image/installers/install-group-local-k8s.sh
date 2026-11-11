#!/usr/bin/env bash
set -euo pipefail
source /usr/local/lib/agentbox/lib/user-install.sh
BIN="$(agentbox_user_bin)"
ARCH="$(agentbox_arch)"
KIND_VERSION="${KIND_VERSION:-v0.26.0}"
K3D_VERSION="${K3D_VERSION:-v5.7.5}"
agentbox_fetch_bin "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${ARCH}" "${BIN}/kind"
agentbox_fetch_bin "https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-${ARCH}" "${BIN}/k3d"
echo "Installed kind, k3d → ${BIN}"
echo "These need a Docker socket (-D / --trusted) to create clusters."
kind version
k3d version
