#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install npm if not installed
if ! command_exists npm; then
    echo "npm not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y npm
    echo "npm installed"
else
    echo "npm installed"
fi

# Install TiddlyWiki if not installed
if ! command_exists tiddlywiki; then
    echo "TiddlyWiki not found. Installing..."
    sudo npm install -g tiddlywiki@5.2.3
    echo "TiddlyWiki installed"
else
    echo "TiddlyWiki installed"
fi

exit 0
