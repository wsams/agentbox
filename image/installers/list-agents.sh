#!/usr/bin/env bash
set -euo pipefail

candidates=(agent cursor-agent claude copilot grok gemini codex opencode)
echo "Agent CLIs on PATH:"
found=0
for c in "${candidates[@]}"; do
  if command -v "${c}" >/dev/null 2>&1; then
    loc="$(command -v "${c}")"
    ver="$("${c}" --version 2>/dev/null | head -1 || true)"
    printf '  %-14s %s' "${c}" "${loc}"
    [[ -n "${ver}" ]] && printf '  (%s)' "${ver}"
    printf '\n'
    found=1
  else
    printf '  %-14s (not installed)\n' "${c}"
  fi
done
if [[ -n "${AGENT_CMD:-}" ]]; then
  echo "AGENT_CMD=${AGENT_CMD}"
fi
if [[ "${found}" -eq 0 && -z "${AGENT_CMD:-}" ]]; then
  echo
  echo "None installed yet. Run: wizard"
fi
