#!/bin/bash

# Load .env file
source /workspace/runpod-playground/.env

cd $LIBRARY_BASE_PATH

# Install python3.11
if ! command -v python3.11 >/dev/null 2>&1; then
    echo "******** Updating apt ********"
    apt update -y -qq > /dev/null
    echo "******** Installing python3.11 ********"
    add-apt-repository ppa:deadsnakes/ppa -y && apt update -y -qq > /dev/null
    DEBIAN_FRONTEND=noninteractive TZ=Europe/Turkey apt install python3.11-full -y -qq > /dev/null
fi

# Install uv
if ! command -v uv >/dev/null 2>&1; then
    echo "******** Installing uv ********"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    source $HOME/.cargo/env bash

    if [ ! -d $LIBRARY_BASE_PATH/.venv ]; then
        echo "******** Creating virtual environment using uv with python3.11 ********"
        uv venv --python python3.11
    fi
fi