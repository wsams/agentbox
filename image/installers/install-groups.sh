#!/usr/bin/env bash
# Install one or more OSS tool groups into the user environment.
# Usage: install-groups.sh ansible,secrets,gitops
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $# -lt 1 || -z "${1:-}" ]]; then
  echo "Usage: $(basename "$0") <group>[,group…]" >&2
  echo "Groups: ansible secrets gitops supplychain local-k8s mesh rclone golang vault" >&2
  exit 2
fi

IFS=',' read -ra groups <<<"$1"
for raw in "${groups[@]}"; do
  g="$(echo "${raw}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')"
  [[ -n "${g}" ]] || continue
  case "${g}" in
    ansible) script="${ROOT}/install-group-ansible.sh" ;;
    secrets) script="${ROOT}/install-group-secrets.sh" ;;
    gitops) script="${ROOT}/install-group-gitops.sh" ;;
    supplychain) script="${ROOT}/install-group-supplychain.sh" ;;
    local-k8s|local_k8s) script="${ROOT}/install-group-local-k8s.sh" ;;
    mesh) script="${ROOT}/install-group-mesh.sh" ;;
    rclone) script="${ROOT}/install-group-rclone.sh" ;;
    golang|go) script="${ROOT}/install-group-golang.sh" ;;
    vault) script="${ROOT}/install-vault.sh" ;;
    *)
      echo "Unknown group: ${g}" >&2
      exit 1
      ;;
  esac
  echo "═══ Installing group: ${g} ═══"
  bash "${script}"
done
echo "All requested groups finished."
