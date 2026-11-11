#!/usr/bin/env bash
# Ansible + ansible-lint (GPL-3.0 / community) — safe to publish.
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  ansible \
  ansible-lint \
  python3-jmespath \
  sshpass
apt-get clean
rm -rf /var/lib/apt/lists/*
ansible --version
ansible-lint --version || true
