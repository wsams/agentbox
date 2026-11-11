#!/bin/sh
set -eu
ALLOW="${ALLOW_FILE:-/etc/egress.allow}"
CONF=/etc/tinyproxy/tinyproxy.conf

mkdir -p /etc/tinyproxy
cat >"${CONF}" <<'EOF'
User nobody
Group nobody
Port 8888
Listen 0.0.0.0
Timeout 600
LogLevel Info
MaxClients 100
DisableViaHeader Yes
EOF

if [ -f "${ALLOW}" ]; then
  echo "FilterDefaultDeny Yes" >>"${CONF}"
  # tinyproxy Filter file: one domain per line
  FILTER=/etc/tinyproxy/filter
  : >"${FILTER}"
  while IFS= read -r line || [ -n "${line}" ]; do
    case "${line}" in
      ''|\#*) continue ;;
    esac
    # Strip leading dot for tinyproxy
    domain="${line#.}"
    echo "${domain}" >>"${FILTER}"
  done < "${ALLOW}"
  echo "Filter \"${FILTER}\"" >>"${CONF}"
  echo "FilterURLs On" >>"${CONF}"
fi

exec tinyproxy -d -c "${CONF}"
