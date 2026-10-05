#!/bin/sh
# Uploads start.sh and setup.sh to ~/xray on alwaysdata over SSH and runs setup.sh there (macOS / Linux).
#
#   ./install.sh account@ssh-account.alwaysdata.net
set -eu
if [ $# -ne 1 ]; then
    echo "Usage: ./install.sh account@ssh-account.alwaysdata.net" >&2
    exit 1
fi
cd "$(dirname "$0")"

tar -cf - start.sh setup.sh | ssh "$1" \
    "cd ~ && { [ ! -f xray ] || mv xray xray.old; } && mkdir -p xray && tar -xf - -C xray --exclude='._*' --warning=no-unknown-keyword && bash xray/setup.sh"
