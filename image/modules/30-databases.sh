#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  postgresql-client \
  mariadb-client \
  redis-tools \
  sqlite3
# mongosh
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc \
  | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" \
  >/etc/apt/sources.list.d/mongodb-org-7.0.list
apt-get update
apt-get install -y --no-install-recommends mongodb-mongosh || true
apt-get clean
rm -rf /var/lib/apt/lists/*
