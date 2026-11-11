#!/usr/bin/env bash
# Install Anthropic Claude Code CLI via npm (operator download, not baked into the image).
set -euo pipefail

export npm_config_prefix="${HOME}/.npm-global"
mkdir -p "${npm_config_prefix}"
export PATH="${npm_config_prefix}/bin:${PATH}"

echo "Installing Claude Code (@anthropic-ai/claude-code)…"
echo "Subject to Anthropic's terms for Claude Code."
npm install -g @anthropic-ai/claude-code

echo "Installed. Try: claude"
echo "Auth: claude auth login   or set ANTHROPIC_API_KEY"
