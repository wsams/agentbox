# agentbox

A modular **devops toolbox** container you can run against any work directory. Use it for git, cloud CLIs, Kubernetes, Terraform/Pulumi, security scanners, and the rest of the tooling matrix — then, **inside the container**, install whichever AI agent CLIs you want (Cursor, Claude Code, Copilot, Grok, Gemini, Codex, OpenCode, or your own binary).

Proprietary agent binaries are **not** baked into published Docker Hub images. You download them at runtime under each vendor’s terms.

Published images: [`wsams/agentbox`](https://hub.docker.com/r/wsams/agentbox).

## Two wizards

| Where | Command | Purpose |
|---|---|---|
| **Host** (this repo) | `./wizard.py` | Build flavors, start/stop capsules, trigger Renovate, … |
| **Inside the container** | `wizard` | Install AI agent CLIs into that container |

```bash
./wizard.py                 # project operator wizard
./capsule ~/projects/myrepo
# inside:
wizard                      # install Cursor / Claude / Copilot / Grok / …
run-agent                   # AGENT_CMD, or first agent found on PATH
```

## Flavors

Same modular `Dockerfile`; feature groups flip via `build.conf` / `flavors/*.conf`:

| Tag | Intent |
|---|---|
| `wsams/agentbox:core` | Lean daily driver — shells, git/gh, Python/Node, Docker CLI, utilities |
| `wsams/agentbox:k8s` | Core + kubectl, helm, k9s, stern, kubectx/kubens, kustomize, … |
| `wsams/agentbox:terraform` | Core + terraform, tflint, terraform-docs |
| `wsams/agentbox:pulumi` | Core + Pulumi CLI / language hosts |
| `wsams/agentbox:full` | Every feature group enabled |
| `wsams/agentbox-proxy` | Allowlist HTTP proxy for the **filtered** profile |

## Tooling map

| Group | What you get |
|---|---|
| *(always)* | fish/bash/zsh, vim, git, gh, lazygit, Docker CLI + buildx, Python 3 + uv, Node.js LTS, jq/yq, ripgrep/fd/bat/fzf/delta, network basics, in-container `wizard` + agent installers, optional Cursor **skills** (e.g. agent-wizardry) |
| `network` | grpcurl |
| `databases` | psql, mysql/mariadb client, redis-cli, sqlite3, mongosh |
| `aws` / `gcp` / `azure` | Cloud CLIs |
| `terraform` | terraform, tflint, terraform-docs |
| `pulumi` | pulumi, crd2pulumi |
| `security` | trivy, gitleaks, syft |
| `k8s` | kubectl, helm (no repos pre-added), k9s, stern, kubectx, kubens, helm-diff |
| `k8s-extras` | kustomize, kubeconform, kube-linter, kubectl-neat |
| `container-tools` | dive, crane |
| `argocd` | argocd CLI |
| `rust` | rustup / cargo |

## Prerequisites

- A Docker daemon
- Host arches where you can run Linux containers (`linux/amd64`, `linux/arm64`)

## Quick start

```bash
./wizard.py
# or:
./build.sh --flavor core
./capsule ~/projects/myrepo

# Inside the container
wizard                         # pick an agent to install
agent                          # after installing Cursor, for example
```

## Profiles (`capsule`)

| Profile | Flag | Shape |
|---|---|---|
| `sealed` | *(default)* | `/work` RW, git identity, open network, private BuildKit. No Docker socket / history / SSH / tokens unless flagged. |
| `filtered` | `--filtered` | No credentials; HTTP(S) via `egress.conf`. |
| `trusted` | `--trusted` | Docker socket, history, SSH, GitHub tokens, sudo. |

Privilege knobs on sealed/filtered: `-D`, `--sudo`, `--ssh`, `-A`, `--history`, `-G`, `--cursor-auth`, `-k` / `-L`.

## Build

```bash
./build.sh --list-features
./build.sh --flavor core
./build.sh --flavor k8s --push
```

### Skills

Open skill repos in `skills.conf` (default: [`wsams/agent-wizardry`](https://github.com/wsams/agent-wizardry)) and local folders under `skills/<name>/SKILL.md` (for example `skills/audit-project`) are baked under `/home/agent/.cursor/skills/`. That is skill content, not a vendor agent binary.

`audit-project` is a generic audit skill (CVEs, secrets, misconfig, supply chain) usable by any agent that loads skills from that tree.

## Custom agents

```bash
./capsule --agent-cmd /path/to/my-agent ~/projects/myrepo
# or inside:
export AGENT_CMD=my-agent
run-agent
```

## GitHub Actions

- **build-push** — flavor matrix → Docker Hub (`DOCKERHUB_USERNAME`, `DOCKERHUB_TOKEN`)
- **Renovate** — nightly + dispatch (`RENOVATE_TOKEN`, enable auto-merge)
- **semantic-release** — on `main` (`GITHUB_TOKEN`; Conventional Commits)

## Layout

```
Dockerfile                 # ARG-gated feature modules (no vendor agents)
build.sh / flavors/        # feature resolution + skill staging
capsule                    # start / attach / down
image/installers/          # runtime agent install scripts
image/wizard/              # in-container wizard catalog
wizard.py                  # host project wizard
wizard/catalog.json
proxy/                     # filtered-profile allowlist proxy
```

## Publishing note

Hub images intentionally omit Cursor / Claude / Copilot / Grok / … binaries. The in-container `wizard` fetches them when you ask. Do not commit vendor agent tarballs into this repo or bake them into tags you push.
