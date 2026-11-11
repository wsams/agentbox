#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing OpenCode CLI (opencode-ai)…"
# Open-source agent CLI; package name on npm is opencode-ai
npm install -g opencode-ai

echo "Installed. Try: opencode"
echo "Configure providers per OpenCode docs (API keys for the models you use)."
