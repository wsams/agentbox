#!/usr/bin/env bash
# Base OS packages, user, and paths shared by every flavor.
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  software-properties-common \
  apt-transport-https \
  sudo \
  gosu \
  locales \
  tzdata \
  unzip \
  zip \
  xz-utils \
  tar \
  gzip \
  bzip2 \
  less \
  man-db \
  procps \
  psmisc \
  file \
  rsync \
  openssh-client \
  git \
  make \
  build-essential \
  pkg-config \
  python3 \
  python3-pip \
  python3-venv \
  fish \
  bash \
  zsh \
  vim \
  nano \
  tmux \
  screen \
  htop \
  tree \
  jq \
  ripgrep \
  fd-find \
  fzf \
  bat \
  silversearcher-ag \
  shellcheck \
  direnv \
  pandoc \
  socat \
  netcat-openbsd \
  whois \
  traceroute \
  dnsutils \
  iproute2 \
  iputils-ping \
  mtr-tiny \
  tcpdump \
  gettext-base

ln -sf "$(command -v fdfind)" /usr/local/bin/fd
ln -sf "$(command -v batcat)" /usr/local/bin/bat

locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8

groupadd --gid 1000 agent
useradd --uid 1000 --gid agent --shell /usr/bin/fish --create-home agent
echo 'agent ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/agent
chmod 0440 /etc/sudoers.d/agent

install -d -o agent -g agent \
  /home/agent/.local/bin \
  /home/agent/.local/share \
  /home/agent/.local/share/fish \
  /home/agent/.config \
  /home/agent/.config/fish/conf.d \
  /home/agent/.cursor/skills \
  /home/agent/.kube \
  /work

ARCH="$(uname -m)"
case "${ARCH}" in
  x86_64|amd64) BIN_ARCH=amd64; LG_ARCH=x86_64; DELTA_ARCH=x86_64 ;;
  aarch64|arm64) BIN_ARCH=arm64; LG_ARCH=arm64; DELTA_ARCH=aarch64 ;;
  *) echo "unsupported arch: ${ARCH}" >&2; exit 1 ;;
esac

YQ_VERSION="${YQ_VERSION:-v4.44.3}"
curl -fsSL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${BIN_ARCH}" \
  -o /usr/local/bin/yq
chmod +x /usr/local/bin/yq

DELTA_VERSION="${DELTA_VERSION:-0.18.2}"
curl -fsSL "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/delta-${DELTA_VERSION}-${DELTA_ARCH}-unknown-linux-gnu.tar.gz" \
  -o /tmp/delta.tgz
tar -xzf /tmp/delta.tgz -C /tmp
install -m 0755 /tmp/delta-*/delta /usr/local/bin/delta
rm -rf /tmp/delta.tgz /tmp/delta-*

curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  >/etc/apt/sources.list.d/github-cli.list
apt-get update
apt-get install -y gh

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  >/etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y --no-install-recommends docker-ce-cli docker-buildx-plugin docker-compose-plugin
groupadd -f docker
usermod -aG docker agent

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs

curl -fsSL https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh

LAZYGIT_VERSION="${LAZYGIT_VERSION:-0.44.1}"
curl -fsSL "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_${LG_ARCH}.tar.gz" \
  -o /tmp/lazygit.tgz
tar -xzf /tmp/lazygit.tgz -C /tmp lazygit
install -m 0755 /tmp/lazygit /usr/local/bin/lazygit
rm -f /tmp/lazygit /tmp/lazygit.tgz

apt-get clean
rm -rf /var/lib/apt/lists/*
