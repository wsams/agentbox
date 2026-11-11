# agentbox

You are inside an **agentbox** container. The workspace is `/work`.

This image is a **devops toolbox**. It does **not** ship proprietary AI agent binaries (Cursor, Claude Code, Copilot, Grok, …). Install those yourself:

```bash
wizard                 # in-container installer wizard
wizard --list
run-agent              # runs AGENT_CMD, or the first known agent on PATH
```

## Custom agents

```bash
export AGENT_CMD=/path/to/your-agent
run-agent
```

Or launch the capsule with `--agent-cmd`.

## Persistence

Agent installs go under `/home/agent` (`~/.local`, `~/.npm-global`). They last until the container is removed or recreated unless you bind-mount that home directory.
