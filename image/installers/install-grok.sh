#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing Grok CLI (@xai-official/grok)…"
echo "Subject to xAI terms."
npm install -g @xai-official/grok

if [[ -x "${HOME}/.npm-global/bin/grok" || -x "${HOME}/.grok/bin/grok" ]]; then
  echo "Installed. Try: grok"
  echo "Auth: grok login   or set XAI_API_KEY"
else
  echo "Install finished but grok was not found under ~/.npm-global/bin." >&2
  exit 1
fi
