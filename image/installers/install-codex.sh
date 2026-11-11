#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing OpenAI Codex CLI (@openai/codex)…"
npm install -g @openai/codex

echo "Installed. Try: codex"
echo "Auth: set OPENAI_API_KEY or follow codex login as documented upstream"
