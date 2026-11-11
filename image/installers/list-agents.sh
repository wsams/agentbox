#!/usr/bin/env bash
set -euo pipefail

candidates=(agent cursor-agent claude copilot grok gemini codex opencode)

echo "Agent CLIs:"
echo "(wrappers in /usr/local/bin install on first run; real installs live under ~/.local or ~/.npm-global)"
echo

for c in "${candidates[@]}"; do
  real=""
  for dir in "${HOME}/.npm-global/bin" "${HOME}/.local/bin" "${HOME}/.grok/bin"; do
    if [[ -x "${dir}/${c}" ]]; then
      real="${dir}/${c}"
      break
    fi
  done
  wrapper="/usr/local/bin/${c}"
  if [[ -n "${real}" ]]; then
    ver="$("${real}" --version 2>/dev/null | head -1 || true)"
    printf '  %-14s installed  %s' "${c}" "${real}"
    [[ -n "${ver}" ]] && printf '  (%s)' "${ver}"
    printf '\n'
  elif [[ -x "${wrapper}" ]]; then
    printf '  %-14s wrapper    %s  (installs on first run)\n' "${c}" "${wrapper}"
  else
    printf '  %-14s missing\n' "${c}"
  fi
done

if [[ -n "${AGENT_CMD:-}" ]]; then
  echo
  echo "AGENT_CMD=${AGENT_CMD}"
fi
