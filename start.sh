#!/bin/sh
# Xray relay (VLESS over XHTTP), started by an alwaysdata "User program" site.
# alwaysdata sets IP and PORT; UUID and XHTTP_PATH come from secrets.env (created by setup.sh).
#
# ./start.sh --check validate the config without starting Xray
set -eu
cd "$(dirname "$0")"

[ "${1:-}" = --check ] && IP=:: PORT=1 # placeholders: the check doesn't listen anywhere

. ./secrets.env
: "${UUID:?UUID is missing in secrets.env}"
: "${XHTTP_PATH:?XHTTP_PATH is missing in secrets.env}"
: "${IP:?IP is not set: start.sh is meant to be run by alwaysdata}"
: "${PORT:?PORT is not set: start.sh is meant to be run by alwaysdata}"

config() {
    cat <<EOF
{
  "log": { "loglevel": "warning", "access": "none" },
  "inbounds": [{
    "listen": "$IP",
    "port": $PORT,
    "protocol": "vless",
    "settings": { "users": [{ "id": "$UUID" }], "decryption": "none" },
    "streamSettings": {
      "network": "xhttp",
      "xhttpSettings": { "path": "$XHTTP_PATH", "mode": "auto" },
      "sockopt": { "trustedXForwardedFor": ["X-Forwarded-For"] }
    }
  }],
  "outbounds": [{ "protocol": "freedom" }]
}
EOF
}

if [ "${1:-}" = --check ]; then
    config | ./xray run -test -c stdin:
else
    umask 077
    config > config.json
    exec ./xray run -c config.json
fi
