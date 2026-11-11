---
name: audit-project
description: >-
  Audits a software project for CVEs, vulnerable dependencies, leaked secrets,
  risky configs, supply-chain gaps, and other security or quality problems.
  Produces a severity-ranked report with evidence and next steps. Use when the
  user asks to audit a project, run a security review, scan for CVEs,
  vulnerabilities, secrets, misconfigurations, or dependency risk.
---

# Audit Project

You are the agent. Audit the repository (or path) in front of you. This skill is not tied to one agent product.

Do not “fix” findings unless the user asks. Prefer evidence over speculation. Prefer running real scanners when they exist over guessing.

## Scope

Default scope: the current project root. If the user names a path, subdirectory, image, or lockfile, limit the audit to that.

Skip generated noise unless it is what gets shipped: `node_modules/`, `vendor/` (unless vendored source is the product), `.git/`, build outputs, caches.

## Workflow

Copy and track:

```
Audit progress:
- [ ] 1. Inventory
- [ ] 2. Tooling available
- [ ] 3. Dependency / CVE scans
- [ ] 4. Secrets and sensitive data
- [ ] 5. Container / IaC / CI
- [ ] 6. Config and auth footguns
- [ ] 7. Report
```

### 1. Inventory

Identify what the project is:

- Languages and package managers (`package-lock.json`, `pnpm-lock.yaml`, `yarn.lock`, `requirements*.txt`, `poetry.lock`, `Pipfile.lock`, `go.mod`, `Cargo.lock`, `Gemfile.lock`, `composer.lock`, etc.)
- Runtime artifacts: `Dockerfile*`, Compose, Helm, Terraform, Pulumi, Kubernetes manifests
- CI: `.github/workflows/`, other pipelines
- Entry points: servers, CLIs, scripts that handle untrusted input
- Documented secrets/env vars (names only from `.env.example` / README — never print secret values)

### 2. Tooling available

Detect scanners on `PATH` (and language toolchains). Use what exists; do not fail the whole audit if a tool is missing — note the gap and continue with the next best method.

Prefer, when present:

| Concern | Tools (use first match that works) |
|---|---|
| FS / image / lockfile CVEs | `trivy`, `grype`, `osv-scanner`, `npm audit`, `pip-audit`, `govulncheck`, `cargo audit` |
| SBOM | `syft`, `trivy image --format cyclonedx` |
| Secrets | `gitleaks`, `trufflehog`, `detect-secrets` |
| Dockerfile / K8s / IaC | `trivy config`, `hadolint`, `kube-linter`, `kubeconform`, `tflint`, `tfsec` / `trivy config` |
| Shell | `shellcheck` |

Exact commands: [tools.md](tools.md).

### 3. Dependency / CVE scans

- Run ecosystem-native audit commands for lockfiles you found.
- If Trivy/Grype/OSV exist, scan the repo filesystem; if a Dockerfile or image tag is in scope, scan that too.
- Record CVE/advisory ids, severity, package, installed version, fixed version when known.
- Treat unreachable or transitive noise honestly: still list High/Critical; mark lower severities or unreachable paths as such when you can justify it.

### 4. Secrets and sensitive data

- Run a secret scanner when available.
- Manually spot-check for private keys, tokens, `.env` files, credentials in workflows, and “example” values that look real.
- **Never** echo raw secrets into the report. Cite file path + finding type + redacted hint only.

### 5. Container / IaC / CI

- Dockerfiles: root daemons, broad `ADD`/`COPY` of secrets, unpinned base tags `:latest`, unnecessary packages, missing non-root user when one is expected.
- Compose/K8s: privileged pods, hostPath, hostNetwork, weak RBAC, secrets in env literals.
- Terraform/Pulumi: public resources, open security groups, plaintext state assumptions.
- CI: `pull_request_target` with untrusted checkout, wide `permissions: write-all`, secrets in fork PRs, unpinned third-party actions (`@main` / `@master`).

### 6. Config and auth footguns

Project-appropriate checks only (skip what does not apply):

- Debug/mode flags left on for production
- CORS `*`, missing auth on admin routes, CSRF gaps
- Dangerous shell (`eval`, unsanitized `subprocess` with shell=True, SQL string concat)
- World-writable scripts, setuid bits, predictable temp paths
- Dependency confusion signals (unusual private package names without registry config)

### 7. Report

Write the report in the chat (and to a file only if the user asks). Use this shape:

```markdown
# Project audit: <name or path>

## Summary
- Scope: …
- Stack: …
- Tools run: … (and tools missing: …)
- Counts: Critical N · High N · Medium N · Low N · Info N

## Findings

### CRITICAL
- **[id] Title** — evidence (path / package / CVE) — impact — recommended fix

### HIGH
…

### MEDIUM
…

### LOW / INFO
…

## Gaps
Scans that could not run and why (missing tool, no lockfile, offline, …).

## Suggested next actions
Ordered, concrete (upgrade X to Y, pin action SHA, remove file Z, …).
```

Severity:

- **Critical** — exploitable or actively dangerous in default use (RCE, auth bypass, secret in repo)
- **High** — serious vulnerability or likely exploit path
- **Medium** — real issue with constraints or harder exploit
- **Low** — hardening / best practice
- **Info** — observation, missing scan coverage, informational CVE noise

## Rules

1. Do not invent CVEs. If a scanner did not run, say so.
2. Do not dump full SBOM or raw scanner JSON unless asked; summarize.
3. Do not rotate or delete credentials yourself unless the user explicitly asks.
4. Prefer fixes that match how this repo already manages deps (Renovate, lockfiles, base image digests).
5. If the repo is `agentbox` (or similar toolbox images), also check that proprietary agent CLIs are not being redistributed in published artifacts.

## Additional resources

- Scanner command cheatsheet: [tools.md](tools.md)
- Example report tone: [examples.md](examples.md)
