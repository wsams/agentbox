# agentbox

DevOps toolbox containers with optional **runtime** AI agent installs. Prefer `./wizard.py` on the host. Inside a running capsule, prefer `wizard` to install agent CLIs. Published flavors: `core`, `k8s`, `terraform`, `pulumi`, `full` on `wsams/agentbox`.

## Conventions

- **Do not bake proprietary agent binaries** (Cursor, Claude Code, Copilot, Grok, …) into images pushed to Docker Hub. Ship lazy wrappers (`image/wrappers/`), installers (`image/installers/`), and the in-container wizard only.
- First-run wrappers on `PATH` (`agent`, `claude`, …) call the matching installer when `~/.local` / `~/.npm-global` does not yet have the binary. `AGENTBOX_NO_AUTO_INSTALL=1` disables that.
- Two wizards: host `./wizard.py` + `wizard/catalog.json`; in-container `wizard` + `image/wizard/catalog.json` (installed to `/usr/local/lib/agentbox`).
- Custom agents use `AGENT_CMD` / `capsule --agent-cmd` / `run-agent`.
- Launcher is `./capsule`. Profiles: `sealed`, `filtered`, `trusted`.
- Feature groups: `build.conf` / `flavors/*.conf` and `WITH_*` Dockerfile args. Install logic lives in `image/modules/`.
- No Tanzu, vSphere, private LLM gateways, or preconfigured Helm repos.
- Open skills in `skills.conf` and local `skills/<name>/` install under `/home/agent/.cursor/skills/` (content, not agent binaries). Local example: `skills/audit-project` for CVE / secret / misconfig audits.
- Conventional Commits for semantic-release on `main`.
- Renovate nightly needs `RENOVATE_TOKEN` + auto-merge; release uses `GITHUB_TOKEN`.

## Agent Wizardry

This project ships a wizard. `wizard/catalog.json` is the map of what a person can do here. The operator wizard is a program in this project's language. Later agents keep that program and the catalog together.

- Catalog: `wizard/catalog.json` (host). In-container catalog: `image/wizard/catalog.json` (shipped as `/usr/local/lib/agentbox/wizard/catalog.json`).
- Operator wizard: `python wizard.py` (host). In-container: `wizard`.
- Product wizard: none
- Web catalog: none

When you add, rename, remove, or change a script, task-runner target, package script, GitHub Actions workflow, Compose service, documented command, CLI flag, environment variable a person must set, or a user-facing flow:

1. Update `wizard/catalog.json` in the same change. Re-read the source first. Record real flags, defaults, and paths. Leave out anything you cannot find in the repo.
2. Update the operator wizard only when its behavior no longer matches the catalog. Keep it in the language it was written in.
3. Set `danger` from the effect of the task. `safe` does not write or delete. `writes` changes local, remote, or shared state. `destructive` deletes, overwrites, or deploys in a way that is hard to undo. `writes` and `destructive` set `confirm` to true.
4. Keep operator commands on the `cli` surface. Keep product guidance on the `web` surface. A web task has steps or a link and has no `run` command.
5. Keep one catalog. When a product wizard exists, regenerate its web catalog from `wizard/catalog.json`. When the catalog has placements, each wizard mark opens only the tasks for that place. Do not keep a second task list in the UI.
6. Validate against the Agent Wizardry catalog spec, and fix what it reports. Use the skill's `validate_catalog.py` when it is available.
7. Leave the wizard in place. A change that adds a way to run the project also updates the wizard.
