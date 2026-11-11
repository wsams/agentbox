#!/usr/bin/env bash
set -euo pipefail

# Apply forwarded git identity when present
if [[ -n "${GIT_USER_NAME:-}" ]]; then
  git config --global user.name "${GIT_USER_NAME}"
fi
if [[ -n "${GIT_USER_EMAIL:-}" ]]; then
  git config --global user.email "${GIT_USER_EMAIL}"
fi

# Disable sudo unless AGENTBOX_SUDO=1
if [[ "${AGENTBOX_SUDO:-0}" != "1" ]]; then
  if [[ -f /etc/sudoers.d/agent ]]; then
    rm -f /etc/sudoers.d/agent
  fi
fi

cd /work

# Drop to agent unless already that user
if [[ "$(id -u)" -eq 0 ]]; then
  exec gosu agent "$@"
fi
exec "$@"
