#!/usr/bin/env bash
# Runs on the alwaysdata server (uploaded by install.sh): installs Xray, creates secrets.env,
# prints the client link and saves it to link.txt.
set -euo pipefail
cd "$(dirname "$0")"
umask 077

XHTTP_MODE=packet-up # the alwaysdata proxy breaks stream-up and stream-one
ACCOUNT=$(id -un)
SITE=$ACCOUNT.alwaysdata.net

# Newest release, pre-releases included (the "latest" stable one is too old for start.sh)
[[ $(curl -fsSL https://github.com/XTLS/Xray-core/releases.atom) =~ releases/tag/(v[0-9.]+) ]] ||
    { echo "Could not determine the latest Xray version" >&2; exit 1; }
XRAY_VERSION=${BASH_REMATCH[1]}

if [[ $(./xray version 2>/dev/null) != *" ${XRAY_VERSION#v} "* ]]; then
    zip=Xray-linux-64.zip
    curl -fsSLO "https://github.com/XTLS/Xray-core/releases/download/$XRAY_VERSION/$zip{,.dgst}"
    echo "$(sed -n 's/^SHA2-256= //p' $zip.dgst)  $zip" | sha256sum -c --quiet
    unzip -oq $zip xray
    rm $zip $zip.dgst
fi

[ -f secrets.env ] || printf 'UUID=%s\nXHTTP_PATH=/%s\n' "$(./xray uuid)" "$(./xray uuid | tr -d -)" > secrets.env
. ./secrets.env

chmod 700 start.sh
./start.sh --check | tail -1
echo "Site: User program, command $PWD/start.sh (restart the site after updates)"
echo "vless://$UUID@$SITE:443?encryption=none&security=tls&sni=$SITE&type=xhttp&host=$SITE&path=${XHTTP_PATH//\//%2F}&mode=$XHTTP_MODE#$ACCOUNT" | tee link.txt
