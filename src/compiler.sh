#!/bin/bash
cd $( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
. bash_colors.sh
VENV=".venv"
BORG_NAME="MYBORG"
PLAINTEXT_PASSPHRASE="12345678"
ENCRYPTED_PASSPHRASE="yEGDBcJ2lKcFdhhay2kJDg=="
set -e

doSetup(){
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
        python-jose \
        pycryptodome \
            >/dev/null
    pip install -r ../requirements.d/development.txt >/dev/null
    pip install -e ../ >/dev/null
}

doTestBorg(){
    if [[ "$1" == "" ]]; then
        echo "[doTestBorg] : missing argument"
        exit 1
    fi
    clr_green Testing borg with $1
    env | egrep "BORG_|AUTH_TOKEN|PUBLIC_KEY|AUDIENCE"
    $1 --version

    echo 1234 > testfile.txt
    rm -rf test.borg
    $1 init -e repokey test.borg
    ls -al test.borg

    echo; clr_green Borging with plaintext passphrase; echo
    $1 create test.borg::test1 testfile.txt
    $1 list test.borg::test1
    echo; clr_green OK; echo

    rm -rf test.borg
}

doPyInstaller(){


    pyinstaller \
        --onedir \
        -y \
        --clean \
        -n $BORG_NAME \
            borg/__main__.py

}





doPassphraseTests(){

    clr_green Testing Borg with $BP
    file $BP

    BORG_PASSPHRASE="$PLAINTEXT_PASSPHRASE" \
        doTestBorg $BP
    echo; clr_green Plaintext with specified passphrase tests pass; echo; echo
    unset BORG_PASSPHRASE


    AUDIENCE="$(cat ~/.keys/audience.key)" \
    PUBLIC_KEY="$(cat ~/.keys/pub.key|base64 -w0)" \
    AUTH_TOKEN="$(generateApplicationToken.sh apiStatus read)" \
        doTestBorg $BP
    echo; clr_green Plaintext passphrase in AUTH_TOKEN tests pass; echo

    AUDIENCE="$(cat ~/.keys/audience.key)" \
    PUBLIC_KEY="$(cat ~/.keys/pub.key|base64 -w0)" \
    AUTH_TOKEN="$(generateApplicationToken.sh araAPI_ro read)" \
        doTestBorg $BP
    echo; clr_green Encrypted passphrase in AUTH_TOKEN tests pass; echo

}

doSetup




BP="$VENV/bin/borg"
doPassphraseTests



doPyInstaller



BP="./dist/$BORG_NAME/$BORG_NAME"
doPassphraseTests

echo; clr_green Pyinstaller tests pass; echo

exit

#pyarmor register \
#    ~/.pyarmor/pyarmor-regfile-1.zip

#pyarmor pack \
#    -t PyInstaller \
#    --clean \
#    -O PACKED \
#    -x " " \
#    -e " " \
#        borg/__main__.py
