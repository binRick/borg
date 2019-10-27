#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )


exec nodemon \
    -V \
    -w borg/crypto/key.py \
    -w compiler.sh \
    -w ~/.keys \
    -w dev.sh \
    -i borgbackup.egg-info \
    -i borg/_version.py \
    -e sh,py,yaml,json,key \
    -x ./compiler.sh
