#!/bin/bash
set -e
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

time PLAINTEXT_PASSPHRASE=$BORG_PASSPHRASE BORG_NAME=VPNTECH_BORG ./compiler.sh
rm -rf ../../../bin/VPNTECH_BORG
mv dist/VPNTECH_BORG ../../../bin
