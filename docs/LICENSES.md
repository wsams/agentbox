# Publishable tooling and licenses

agentbox only **bakes** tools into Docker Hub images when they are open source
(or otherwise clearly redistributable for this use). Anything else is installed
**on demand** via a wrapper or the in-container wizard.

## Baked into published images (feature groups)

| Group | Tools | License (summary) |
|---|---|---|
| base | Ubuntu packages, git, gh, Docker CLI, Node, Python/uv, … | Upstream distro / OSI |
| ansible | ansible, ansible-lint | GPL-3.0 |
| secrets | sops, age | MPL-2.0, BSD |
| gitops | flux | Apache-2.0 |
| supplychain | cosign, skopeo, pack | Apache-2.0 |
| local-k8s | kind, k3d | Apache-2.0, MIT |
| mesh | cilium, hubble, istioctl, linkerd | Apache-2.0 |
| rclone | rclone | MIT |
| golang | Go toolchain | BSD-style (go.dev) |
| terraform | terraform, tflint, terraform-docs | **BSL 1.1** (HashiCorp) + MPL/MIT for helpers |
| pulumi | pulumi, crd2pulumi | Apache-2.0 |
| argocd | argocd | Apache-2.0 |
| security | trivy, gitleaks, syft | Apache-2.0 |
| k8s / k8s-extras | kubectl, helm, k9s, … | Apache-2.0 / upstream |

Terraform (BSL) remains available as its own flavor because operators expect it;
it is not OSI “Open Source,” but HashiCorp’s BSL permits non-competitive use
and redistribution of the binaries in tool images. Prefer OpenTofu later if you
want an OSI-only IaC CLI.

## On-demand only (wrappers / wizard)

| Tool | Why not baked | How to get it |
|---|---|---|
| Cursor `agent`, Claude Code, Copilot, Grok, Gemini, Codex, … | Proprietary vendor terms | Lazy wrappers + wizard |
| HashiCorp **Vault** CLI | BSL 1.1 (not OSI); keep off Hub layers by default | `vault` wrapper or wizard |

Do not commit vendor agent tarballs or Vault binaries into this repository.
