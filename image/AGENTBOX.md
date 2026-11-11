# agentbox

You are inside an **agentbox** container. The workspace is `/work`.

This image is a **devops toolbox**. Proprietary AI agent binaries are not baked in.

## First-run wrappers

Commands like `agent`, `claude`, `copilot`, `grok`, `gemini`, `codex`, and `opencode` are **wrappers**. The first time you run one, it downloads/installs that CLI into your home (`~/.local` or `~/.npm-global`), then execs it. Later runs use the installed binary (those dirs shadow `/usr/local/bin` on `PATH`).

```bash
agent                  # installs Cursor agent on first use, then runs it
claude                 # same for Claude Code
wizard                 # menu of all installers + status
run-agent              # AGENT_CMD, otherwise agent
```

Disable auto-install:

```bash
export AGENTBOX_NO_AUTO_INSTALL=1
```

## Custom agents

```bash
export AGENT_CMD=/path/to/your-agent
run-agent
```

Or launch the capsule with `--agent-cmd`.

## Persistence

Installs under `/home/agent` last until the container is removed or recreated unless you bind-mount that home.
