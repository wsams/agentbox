# Examples

## Trigger phrases

- “Audit this project for CVEs”
- “Security scan the repo”
- “Check for secrets and vulnerable dependencies”
- “Run audit-project on ./services/api”

## Finding line (good)

```markdown
### HIGH
- **[CVE-2024-NNNN] lodash prototype pollution** — `package-lock.json` pins `lodash@4.17.20`; fixed in `4.17.21`.
  Impact: untrusted merge input could pollute Object.prototype.
  Fix: bump lodash to `>=4.17.21` and regenerate the lockfile.
```

## Finding line (bad)

```markdown
- Some dependencies might be outdated.
```

No id, no path, no version, no action.

## Secrets (good)

```markdown
### CRITICAL
- **[secret] AWS access key pattern** — `config/legacy.env:12` (value redacted).
  Fix: remove from git history, rotate the key, load from a secret store.
```

## Gaps (good)

```markdown
## Gaps
- `govulncheck` not installed; Go modules reviewed via `osv-scanner` only.
- No container image tag provided; Dockerfile reviewed with `trivy config` / `hadolint` only.
```
