#!/bin/sh
set -eu

# Required: private DNS hostnames of your three Infisical services
#   INFISICAL1_HOST, INFISICAL2_HOST, INFISICAL3_HOST
# Optional:
#   INFISICAL_PORT   (default: 8080)
#   BIND_PORT        (default: 8080)   - HAProxy public HTTP port
#   STATS_PORT       (default: 8404)
#   STATS_PASSWORD   (optional; if empty, stats page has no auth)
#   RESOLVE_PREFER   (default: ipv4)   - ipv4 | ipv6

: "${INFISICAL1_HOST:?INFISICAL1_HOST is required}"
: "${INFISICAL2_HOST:?INFISICAL2_HOST is required}"
: "${INFISICAL3_HOST:?INFISICAL3_HOST is required}"

INFISICAL_PORT="${INFISICAL_PORT:-8080}"
BIND_PORT="${BIND_PORT:-8080}"
STATS_PORT="${STATS_PORT:-8404}"
RESOLVE_PREFER="${RESOLVE_PREFER:-ipv4}"
STATS_PASSWORD="${STATS_PASSWORD:-}"

export INFISICAL1_HOST INFISICAL2_HOST INFISICAL3_HOST \
  INFISICAL_PORT BIND_PORT STATS_PORT RESOLVE_PREFER STATS_PASSWORD

# Render template
envsubst '${INFISICAL1_HOST} ${INFISICAL2_HOST} ${INFISICAL3_HOST} ${INFISICAL_PORT} ${BIND_PORT} ${STATS_PORT} ${RESOLVE_PREFER} ${STATS_PASSWORD}' \
  < /usr/local/etc/haproxy/haproxy.template.cfg \
  > /usr/local/etc/haproxy/haproxy.cfg

# If STATS_PASSWORD not set, remove auth line to avoid "admin:" with empty pw
if [ -z "$STATS_PASSWORD" ]; then
  sed -i '/stats auth/d' /usr/local/etc/haproxy/haproxy.cfg
fi

exec haproxy -W -db -f /usr/local/etc/haproxy/haproxy.cfg
