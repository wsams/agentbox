#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing GitHub Copilot CLI (@github/copilot)…"
echo "Subject to the GitHub Copilot CLI license / GitHub terms."
npm install -g @github/copilot

if [[ -x "${HOME}/.npm-global/bin/copilot" ]]; then
  echo "Installed. Try: copilot"
  echo "Auth: use gh auth login, or mount host Copilot credentials when launching the capsule"
else
  echo "Install finished but ~/.npm-global/bin/copilot was not found." >&2
  exit 1
fi
