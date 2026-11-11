#!/usr/bin/env bash
# Helpers for userland (~/.local/bin) installs from the in-container wizard.

agentbox_user_bin() {
  mkdir -p "${HOME}/.local/bin"
  printf '%s\n' "${HOME}/.local/bin"
}

agentbox_arch() {
  case "$(uname -m)" in
    x86_64|amd64) printf 'amd64\n' ;;
    aarch64|arm64) printf 'arm64\n' ;;
    *) echo "unsupported arch: $(uname -m)" >&2; return 1 ;;
  esac
}

agentbox_fetch_bin() {
  local url="$1"
  local dest="$2"
  curl -fsSL "${url}" -o "${dest}"
  chmod +x "${dest}"
}
