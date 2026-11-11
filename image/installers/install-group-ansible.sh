#!/usr/bin/env bash
# Install Ansible + ansible-lint into the user environment (GPL-3.0).
set -euo pipefail
export PATH="${HOME}/.local/bin:${PATH}"
echo "Installing ansible + ansible-lint via uv (userland)…"
if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required (shipped in agentbox base)." >&2
  exit 1
fi
uv tool install --force ansible
uv tool install --force ansible-lint
ansible --version
ansible-lint --version || true
echo "Done. Ensure ~/.local/bin is on PATH (it is by default in agentbox)."
