#!/usr/bin/env bash
# Agent runtime scaffolding only — no vendor agent binaries.
# Operators install agents at runtime via the in-container wizard.
set -euo pipefail

install -d -o agent -g agent \
  /home/agent/.local/bin \
  /home/agent/.local/share \
  /home/agent/.npm-global

# User-local npm prefix so global CLIs land on PATH without root
cat >/etc/profile.d/agentbox-npm.sh <<'EOF'
export npm_config_prefix="${HOME}/.npm-global"
export PATH="${HOME}/.npm-global/bin:${HOME}/.local/bin:/usr/local/bin:${PATH}"
EOF

mkdir -p /home/agent/.config/fish/conf.d
cat >/home/agent/.config/fish/conf.d/agentbox-path.fish <<'EOF'
set -gx npm_config_prefix $HOME/.npm-global
fish_add_path $HOME/.npm-global/bin $HOME/.local/bin /usr/local/bin
EOF
chown -R agent:agent /home/agent/.config /home/agent/.npm-global

# run-agent honors AGENT_CMD, else common agent binaries if present
cat >/usr/local/bin/run-agent <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ -n "${AGENT_CMD:-}" ]]; then
  exec ${AGENT_CMD} "$@"
fi
for candidate in agent cursor-agent claude codex grok gemini opencode copilot; do
  if command -v "${candidate}" >/dev/null 2>&1; then
    exec "${candidate}" "$@"
  fi
done
echo "No agent CLI found. Inside this container run: wizard" >&2
echo "Or set AGENT_CMD to your binary." >&2
exit 127
EOF
chmod +x /usr/local/bin/run-agent

echo 'export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:/usr/local/bin:$PATH"' >/etc/profile.d/agentbox-path.sh
