#!/usr/bin/env bash
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing Google Gemini CLI (@google/gemini-cli)…"
npm install -g @google/gemini-cli

echo "Installed. Try: gemini"
echo "Auth: follow gemini login / set GEMINI_API_KEY or GOOGLE_API_KEY as documented upstream"
