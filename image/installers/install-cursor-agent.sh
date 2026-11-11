#!/usr/bin/env bash
# Download Cursor agent from Cursor's CDN into this user's home.
# Not redistributed in the published image — each operator fetches it themselves.
set -euo pipefail

echo "Installing Cursor agent (downloads from downloads.cursor.com)…"
echo "Subject to Cursor Terms of Service: https://cursor.com/terms-of-service"
curl -fsSL https://cursor.com/install | bash

# Ensure common PATH locations
export PATH="${HOME}/.local/bin:${PATH}"
if command -v agent >/dev/null 2>&1 || command -v cursor-agent >/dev/null 2>&1; then
  echo "Installed. Try: agent   (or: cursor-agent)"
  echo "Auth: run agent once to sign in, or export CURSOR_API_KEY"
else
  echo "Installer finished but 'agent' is not on PATH yet."
  echo "Add ~/.local/bin to PATH and reopen the shell."
  exit 1
fi
