#!/usr/bin/env bash
# Agent runtime scaffolding only — no vendor agent binaries.
# Lazy wrappers in /usr/local/bin install on first use; wizard can install explicitly.
set -euo pipefail

install -d -o agent -g agent \
  /home/agent/.local/bin \
  /home/agent/.local/share \
  /home/agent/.npm-global

# User installs must shadow /usr/local/bin wrappers after first install
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

# run-agent: AGENT_CMD, else agent wrapper (which may auto-install Cursor)
cat >/usr/local/bin/run-agent <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
if [[ -n "${AGENT_CMD:-}" ]]; then
  exec ${AGENT_CMD} "$@"
fi
exec /usr/local/bin/agent "$@"
EOF
chmod +x /usr/local/bin/run-agent

echo 'export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:/usr/local/bin:$PATH"' >/etc/profile.d/agentbox-path.sh
