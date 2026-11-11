#!/usr/bin/env bash
set -euo pipefail
export CARGO_HOME=/usr/local/cargo
export RUSTUP_HOME=/usr/local/rustup
curl -fsSL https://sh.rustup.rs | sh -s -- -y --default-toolchain stable --profile minimal
ln -sfn /usr/local/cargo/bin/rustc /usr/local/bin/rustc
ln -sfn /usr/local/cargo/bin/cargo /usr/local/bin/cargo
ln -sfn /usr/local/cargo/bin/rustup /usr/local/bin/rustup
echo 'export PATH="/usr/local/cargo/bin:$PATH"' >/etc/profile.d/rust.sh
