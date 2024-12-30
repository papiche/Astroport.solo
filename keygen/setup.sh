#!/bin/bash
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
hasError=0

## INSTALL SYSTEM PACKAGES
for i in gcc libgpgme-dev python3-pip python3-setuptools libpq-dev python3-dev python3-wheel python3-dotenv python3-gpg python3-jwcrypto python3-brotli python3-aiohttp; do
    if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        [[ ! $j ]] && sudo apt update
        sudo apt install -y $i
        j=1
    fi
done

## INSTALL PYTHON REQUIREMENTS
pip3 install -r requirements.txt || hasError=1

## INSTALL keygen
chmod u+x keygen
sudo ln -sf $(realpath keygen) /usr/local/bin/keygen || hasError=1

if [[ hasError -eq 0 ]]; then
    echo "Setup done. You can use 'keygen' command, try it."
else
    echo "An error has occurred"
fi
