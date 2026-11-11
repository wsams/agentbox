# agentbox

Workspace: `/work`. This image is a **devops toolbox**.

## Agents (on demand)

`agent`, `claude`, `copilot`, `grok`, `gemini`, `codex`, `opencode` are wrappers — first run installs into `~/.local` / `~/.npm-global`.

```bash
agent
wizard                 # menu: agents + OSS tool groups
```

`AGENTBOX_NO_AUTO_INSTALL=1` disables first-run installs.

## Tool groups (on demand)

If your flavor omitted a group, install userland copies:

```bash
wizard
# or:
/usr/local/lib/agentbox/installers/install-groups.sh ansible,secrets,rclone
```

Groups: `ansible`, `secrets`, `gitops`, `supplychain`, `local-k8s`, `mesh`, `rclone`, `golang`, `vault`.

## Vault (BSL)

`vault` is a wrapper (not baked into Hub images). First run downloads under HashiCorp BSL terms.

## Licenses

See `/etc/agentbox/LICENSES.md` for what may be published vs on-demand only.
