#!/bin/sh
# Uploads start.sh and setup.sh to alwaysdata over SSH and runs setup.sh there (macOS / Linux).
#
#   ./install.sh account@ssh-account.alwaysdata.net
set -eu
if [ $# -ne 1 ]; then
    echo "Usage: ./install.sh account@ssh-account.alwaysdata.net" >&2
    exit 1
fi
cd "$(dirname "$0")"

tar -cf - start.sh setup.sh | ssh "$1" \
    "tar -xf - -C ~ --exclude='._*' --warning=no-unknown-keyword && bash ~/setup.sh"
