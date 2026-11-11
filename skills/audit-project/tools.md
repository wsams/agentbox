# Scanner commands

Run from the project root unless noted. Skip any command whose binary is missing. Prefer `--quiet` / table / SARIF only when it helps; default to human-readable output and summarize.

## Filesystem / lockfiles / images

```bash
# Trivy (repo)
trivy fs --severity CRITICAL,HIGH,MEDIUM --scanners vuln,secret,misconfig .

# Trivy (Dockerfile / manifests as config)
trivy config .

# Trivy (local or remote image)
trivy image --severity CRITICAL,HIGH "<image>:<tag>"

# Grype
grype dir:.
grype "<image>:<tag>"

# OSV-Scanner
osv-scanner -r .
```

## Language package audits

```bash
# Node
npm audit --json   # or: npm audit
pnpm audit
yarn npm audit

# Python
pip-audit
pip-audit -r requirements.txt

# Go
govulncheck ./...

# Rust
cargo audit

# Ruby
bundler-audit check

# PHP
composer audit
```

## Secrets

```bash
gitleaks detect --source . --no-git   # or without --no-git for history
# Optional:
# trufflehog filesystem .
# detect-secrets scan
```

## Containers / K8s / IaC / shell

```bash
hadolint Dockerfile
kube-linter lint .
kubeconform -summary .
tflint
shellcheck -x path/to/script.sh
```

## SBOM (only when useful)

```bash
syft . -o table
trivy fs --format cyclonedx --output sbom.cdx.json .
```

## Interpreting results

- Always capture the **command** and **exit context** (scanner error vs clean).
- Deduplicate the same CVE across tools; cite one primary id.
- For image scans, note whether you scanned a **built** image or only the Dockerfile.
