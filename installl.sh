#!/bin/bash

echo "#############################################"
echo "######### INSTALL PYTHON3 SYSTEM LIBRARIES ####"
echo "#############################################"
for i in pipx python3-pip python3-setuptools python3-wheel python3-dotenv python3-gpg python3-jwcrypto python3-brotli python3-aiohttp python3-tk; do
    if [ $(dpkg-query -W -f='${Status}' $i 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
        echo ">>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< Installation $i <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        sudo apt install -y $i
        [[ $? != 0 ]] && echo "INSTALL $i FAILED." && echo "INSTALL $i FAILED." >> /tmp/install.errors.log && continue

    fi
done

echo "#####################################"
echo "## PYTHON TOOLS & CRYPTO LIB ##"
echo "#####################################"
export PATH=$HOME/.local/bin:$PATH
pipx install duniterpy --include-deps ## keeps own dep
## add monero & bitcoin compatible keys
for i in pip python-dotenv setuptools wheel termcolor amzqr pdf2docx requests pyppeteer cryptography jwcrypto Ed25519 gql base58 pybase64 google silkaj pynacl python-gnupg pgpy pynentry paho-mqtt aiohttp ipfshttpclient bitcoin monero ecdsa nostr-relay pynostr bech32; do
        echo ">>> Installation $i <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"
        pip install  $i 2>> /tmp/install.errors.log
        # [[ $? != 0 ]] && pipx install $i 2>> /tmp/install.errors.log
        [[ $? != 0 ]] && echo "INSTALL $i FAILED." && echo "python -m pip install -U $i FAILED." >> /tmp/install.errors.log && continue
done
