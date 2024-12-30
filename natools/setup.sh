#!/bin/bash
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
hasError=0

pip3 install -r requirements.txt || hasError=1
chmod u+x natools.py
sudo ln -sf $(realpath natools.py) /usr/local/bin/natools || hasError=1

if [[ hasError -eq 0 ]]; then
    echo "Setup done. You can use 'natools' command, try it."
else
    echo "An error has occurred"
fi
