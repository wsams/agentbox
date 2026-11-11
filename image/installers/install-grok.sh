#!/usr/bin/env bash
# Install xAI Grok CLI via npm (preferred over curl installer in locked-down networks).
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing Grok CLI (@xai-official/grok)…"
echo "Subject to xAI terms."
npm install -g @xai-official/grok

echo "Installed. Try: grok"
echo "Auth: grok login   or set XAI_API_KEY"
