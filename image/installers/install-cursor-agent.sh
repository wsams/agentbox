#!/usr/bin/env bash
# Download Cursor agent from Cursor's CDN into this user's home.
# Not redistributed in the published image — each operator fetches it themselves.
set -euo pipefail

echo "Installing Cursor agent (downloads from downloads.cursor.com)…"
echo "Subject to Cursor Terms of Service: https://cursor.com/terms-of-service"
curl -fsSL https://cursor.com/install | bash

if [[ -x "${HOME}/.local/bin/agent" || -x "${HOME}/.local/bin/cursor-agent" ]]; then
  echo "Installed under ~/.local/bin. Try: agent"
  echo "Auth: run agent once to sign in, or export CURSOR_API_KEY"
else
  echo "Installer finished but ~/.local/bin/agent was not found." >&2
  exit 1
fi
