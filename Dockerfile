# syntax=docker/dockerfile:1.7
# agentbox — modular devops toolbox. AI agent CLIs are installed at runtime.
# Feature groups are toggled with WITH_* build args (0|1). Prefer build.sh.

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

ARG TARGETARCH
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    AGENTBOX_HOME=/home/agent \
    PATH=/home/agent/.npm-global/bin:/home/agent/.local/bin:/usr/local/bin:/usr/local/cargo/bin:$PATH

# Feature toggles — default on; build.sh / flavors turn groups off.
ARG WITH_NETWORK=1
ARG WITH_DATABASES=1
ARG WITH_AWS=1
ARG WITH_GCP=1
ARG WITH_AZURE=1
ARG WITH_TERRAFORM=1
ARG WITH_PULUMI=1
ARG WITH_SECURITY=1
ARG WITH_K8S=1
ARG WITH_K8S_EXTRAS=1
ARG WITH_CONTAINER_TOOLS=1
ARG WITH_ARGOCD=1
ARG WITH_RUST=1

LABEL org.opencontainers.image.title="agentbox" \
      org.opencontainers.image.description="DevOps toolbox container with optional runtime AI agent installers" \
      org.opencontainers.image.source="https://github.com/wsams/agentbox"

COPY image/modules /tmp/modules
RUN chmod +x /tmp/modules/*.sh

# [group: base] always on
RUN /tmp/modules/00-base.sh

# [group: agent-runtime] PATH, npm prefix, run-agent stub — no vendor binaries
RUN /tmp/modules/10-agent-runtime.sh

# [group: network]
RUN if [ "${WITH_NETWORK}" = "1" ]; then /tmp/modules/20-network.sh; else echo "skip network"; fi

# [group: databases]
RUN if [ "${WITH_DATABASES}" = "1" ]; then /tmp/modules/30-databases.sh; else echo "skip databases"; fi

# [group: aws]
RUN if [ "${WITH_AWS}" = "1" ]; then /tmp/modules/40-aws.sh; else echo "skip aws"; fi

# [group: gcp]
RUN if [ "${WITH_GCP}" = "1" ]; then /tmp/modules/41-gcp.sh; else echo "skip gcp"; fi

# [group: azure]
RUN if [ "${WITH_AZURE}" = "1" ]; then /tmp/modules/42-azure.sh; else echo "skip azure"; fi

# [group: terraform]
RUN if [ "${WITH_TERRAFORM}" = "1" ]; then /tmp/modules/50-terraform.sh; else echo "skip terraform"; fi

# [group: pulumi]
RUN if [ "${WITH_PULUMI}" = "1" ]; then /tmp/modules/51-pulumi.sh; else echo "skip pulumi"; fi

# [group: security]
RUN if [ "${WITH_SECURITY}" = "1" ]; then /tmp/modules/60-security.sh; else echo "skip security"; fi

# [group: k8s]
RUN if [ "${WITH_K8S}" = "1" ]; then /tmp/modules/70-k8s.sh; else echo "skip k8s"; fi

# [group: k8s-extras]
RUN if [ "${WITH_K8S_EXTRAS}" = "1" ]; then /tmp/modules/71-k8s-extras.sh; else echo "skip k8s-extras"; fi

# [group: container-tools]
RUN if [ "${WITH_CONTAINER_TOOLS}" = "1" ]; then /tmp/modules/80-container-tools.sh; else echo "skip container-tools"; fi

# [group: argocd]
RUN if [ "${WITH_ARGOCD}" = "1" ]; then /tmp/modules/81-argocd.sh; else echo "skip argocd"; fi

# [group: rust]
RUN if [ "${WITH_RUST}" = "1" ]; then /tmp/modules/90-rust.sh; else echo "skip rust"; fi

# Optional Cursor skills (open content such as agent-wizardry) — not vendor agent binaries
COPY skills/build /tmp/skills-build
RUN SKILLS_SRC=/tmp/skills-build /tmp/modules/95-skills.sh \
 && rm -rf /tmp/modules /tmp/skills-build

# In-container agent installer wizard + scripts (no proprietary CLIs bundled)
COPY image/installers /usr/local/lib/agentbox/installers
COPY image/wizard /usr/local/lib/agentbox/wizard
COPY image/AGENTBOX.md /usr/local/lib/agentbox/AGENTBOX.md
COPY image/AGENTBOX.md /etc/agentbox/AGENTBOX.md
COPY image/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY image/gitconfig /home/agent/.gitconfig
COPY image/bin/wizard /usr/local/bin/wizard
RUN chmod +x /usr/local/bin/entrypoint.sh /usr/local/bin/wizard \
      /usr/local/lib/agentbox/installers/*.sh \
      /usr/local/lib/agentbox/wizard/wizard.py \
 && chown -R agent:agent /home/agent \
 && mkdir -p /etc/agentbox

LABEL devcontainer.metadata='[{ \
  "remoteUser": "agent", \
  "workspaceFolder": "/work", \
  "remoteEnv": { "PATH": "/home/agent/.npm-global/bin:/home/agent/.local/bin:/usr/local/bin:${containerEnv:PATH}" } \
}]'

WORKDIR /work
USER root
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["fish", "-l"]
