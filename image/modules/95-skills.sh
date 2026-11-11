#!/usr/bin/env bash
# Copy pre-fetched Cursor skills into the agent home.
# build.sh stages them under /tmp/skills-build before this runs (via COPY).
set -euo pipefail
SRC="${SKILLS_SRC:-/tmp/skills-build}"
DEST="/home/agent/.cursor/skills"
install -d -o agent -g agent "${DEST}"
if [[ -d "${SRC}" ]] && [[ -n "$(ls -A "${SRC}" 2>/dev/null || true)" ]]; then
  cp -a "${SRC}/." "${DEST}/"
  chown -R agent:agent "${DEST}"
  if [[ -f "${DEST}/.sources" ]]; then
    echo "Installed skills:"
    cat "${DEST}/.sources"
  fi
else
  echo "No skills staged; image will have an empty skills directory."
fi
