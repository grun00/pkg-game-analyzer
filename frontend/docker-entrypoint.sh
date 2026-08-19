#!/bin/sh
# Render the nginx config from its template, substituting ONLY our own variables
# (${BACKEND_URL}, ${PORT}) so nginx runtime vars like $uri/$host are preserved.
set -eu

: "${BACKEND_URL:=http://web:3000}"
: "${PORT:=80}"

# Derive the container DNS resolver so nginx can resolve the upstream at request
# time. Falls back to Docker's embedded DNS if resolv.conf can't be read.
if [ -z "${RESOLVER:-}" ]; then
  RESOLVER="$(awk '/^nameserver/ { print $2; exit }' /etc/resolv.conf 2>/dev/null || true)"
  : "${RESOLVER:=127.0.0.11}"
fi

# nginx requires IPv6 resolver addresses to be wrapped in [] (otherwise the
# trailing ::N is parsed as a port). Railway's DNS is IPv6 (e.g. fd12::10).
# Strip any existing brackets first, then re-wrap if the address is IPv6.
RESOLVER="$(printf '%s' "$RESOLVER" | tr -d '[]')"
case "$RESOLVER" in
  *:*) RESOLVER="[$RESOLVER]" ;;
esac

export BACKEND_URL PORT RESOLVER

template="/etc/nginx/templates/default.conf.template"
output="/etc/nginx/conf.d/default.conf"

# Disable the stock image's own template renderer to avoid double substitution.
rm -f /docker-entrypoint.d/20-envsubst-on-templates.sh 2>/dev/null || true

envsubst '${BACKEND_URL} ${PORT} ${RESOLVER}' < "$template" > "$output"

echo "[frontend] nginx proxying /api -> ${BACKEND_URL} (resolver ${RESOLVER}), listening on :${PORT}"
