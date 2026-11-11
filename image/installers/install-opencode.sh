#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing OpenCode CLI (opencode-ai)…"
npm install -g opencode-ai

if [[ -x "${HOME}/.npm-global/bin/opencode" ]]; then
  echo "Installed. Try: opencode"
  echo "Configure providers per OpenCode docs (API keys for the models you use)."
else
  echo "Install finished but ~/.npm-global/bin/opencode was not found." >&2
  exit 1
fi
