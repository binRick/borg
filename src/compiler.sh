#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
VENV=".venv"
BORG_NAME="MYBORG"
PLAINTEXT_PASSPHRASE="12345678"
ENCRYPTED_PASSPHRASE="yEGDBcJ2lKcFdhhay2kJDg=="
set -e

sudo yum -y install \
    libacl-devel \
    python3-devel \
    gcc \
    make >/dev/null

python3 -m venv $VENV
source $VENV/bin/activate

pip install pip --upgrade
pip install \
    pyinstaller \
    pyarmor \
    pycryptodome \
        >/dev/null
pip install -r ../requirements.d/development.txt >/dev/null
pip install -e ../ >/dev/null



pyinstaller \
    --onedir \
    -y \
    --clean \
    -n $BORG_NAME \
        borg/__main__.py

echo; echo OK; echo

BP="./dist/$BORG_NAME/$BORG_NAME"

$BP --version

echo 1234 > testfile.txt
rm -rf test.borg
BORG_PASSPHRASE="$PLAINTEXT_PASSPHRASE" $BP init -e repokey test.borg
ls -al test.borg


echo Borging with plaintext passphrase

BORG_PASSPHRASE="$PLAINTEXT_PASSPHRASE" $BP create test.borg::test1 testfile.txt
BORG_PASSPHRASE="$PLAINTEXT_PASSPHRASE" $BP list test.borg::test1
echo; echo OK; echo

echo Borging with encrypted passphrase
BORG_PASSPHRASE_ENCRYPTED="$ENCRYPTED_PASSPHRASE" $BP create test.borg::test2 testfile.txt
BORG_PASSPHRASE_ENCRYPTED="$ENCRYPTED_PASSPHRASE" $BP list test.borg::test2
echo; echo OK; echo

rm -rf test.borg

echo; echo Pyinstaller tests pass; echo


#pyarmor register \
#    ~/.pyarmor/pyarmor-regfile-1.zip

#pyarmor pack \
#    -t PyInstaller \
#    --clean \
#    -O PACKED \
#    -x " " \
#    -e " " \
#        borg/__main__.py
