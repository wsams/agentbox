#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing OpenAI Codex CLI (@openai/codex)…"
npm install -g @openai/codex

if [[ -x "${HOME}/.npm-global/bin/codex" ]]; then
  echo "Installed. Try: codex"
  echo "Auth: set OPENAI_API_KEY or follow codex login as documented upstream"
else
  echo "Install finished but ~/.npm-global/bin/codex was not found." >&2
  exit 1
fi
