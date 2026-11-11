#!/usr/bin/env bash
# Install GitHub Copilot CLI via npm (operator download).
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing GitHub Copilot CLI (@github/copilot)…"
echo "Subject to the GitHub Copilot CLI license / GitHub terms."
npm install -g @github/copilot

echo "Installed. Try: copilot"
echo "Auth: use gh auth login, or mount host Copilot credentials when launching the capsule"
