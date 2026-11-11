#!/usr/bin/env bash
# Shared helper for /usr/local/bin agent wrappers.
# Real binaries live under ~/.local/bin / ~/.npm-global/bin (ahead of
# /usr/local/bin on PATH). Wrappers only run when those are missing.

agentbox_find_real() {
  local self="$1"
  local name="$2"
  local dir candidate resolved
  self="$(readlink -f "${self}" 2>/dev/null || echo "${self}")"
  for dir in "${HOME}/.npm-global/bin" "${HOME}/.local/bin" "${HOME}/.grok/bin"; do
    candidate="${dir}/${name}"
    if [[ -e "${candidate}" || -L "${candidate}" ]]; then
      resolved="$(readlink -f "${candidate}" 2>/dev/null || echo "${candidate}")"
      if [[ "${resolved}" == "${self}" ]]; then
        continue
      fi
      if [[ -x "${candidate}" || -x "${resolved}" ]]; then
        printf '%s\n' "${candidate}"
        return 0
      fi
    fi
  done
  return 1
}

# Usage: agentbox_lazy_run SELF INSTALLER NAME [ALT_NAME...] -- "$@"
agentbox_lazy_run() {
  local self="$1"
  local installer="$2"
  shift 2
  local names=()
  while [[ $# -gt 0 && "$1" != "--" ]]; do
    names+=("$1")
    shift
  done
  if [[ "${1:-}" == "--" ]]; then
    shift
  fi

  local name real=""
  for name in "${names[@]}"; do
    if real="$(agentbox_find_real "${self}" "${name}")"; then
      exec "${real}" "$@"
    fi
  done

  if [[ "${AGENTBOX_NO_AUTO_INSTALL:-0}" == "1" ]]; then
    echo "${names[0]} is not installed. Run: wizard" >&2
    echo "(Auto-install disabled via AGENTBOX_NO_AUTO_INSTALL=1)" >&2
    exit 127
  fi

  echo "▶ ${names[0]} not found — installing on first use…" >&2
  echo "  (Set AGENTBOX_NO_AUTO_INSTALL=1 to disable; or use: wizard)" >&2
  if [[ ! -x "${installer}" ]]; then
    echo "error: installer missing: ${installer}" >&2
    exit 1
  fi
  "${installer}"

  for name in "${names[@]}"; do
    if real="$(agentbox_find_real "${self}" "${name}")"; then
      exec "${real}" "$@"
    fi
  done

  echo "error: install finished but ${names[0]} was not found under ~/.local or ~/.npm-global" >&2
  exit 1
}
