#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

cd $LIBRARY_BASE_PATH

# if ! command -v python$DEPLOYED_PYTHON_VERSION >/dev/null 2>&1; then
#     echo "******** Updating apt ********"
#     apt update -y -qq > /dev/null
#     echo "******** Installing python$DEPLOYED_PYTHON_VERSION ********"
#     add-apt-repository ppa:deadsnakes/ppa -y && apt update -y -qq > /dev/null
#     DEBIAN_FRONTEND=noninteractive TZ=Europe/Turkey apt install python$DEPLOYED_PYTHON_VERSION-full -y -qq > /dev/null
# fi

# Install uv
if ! command -v uv >/dev/null 2>&1; then
    echo "******** Installing uv ********"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    source $HOME/.local/bin/env bash

    # echo "******** Installing python$DEPLOYED_PYTHON_VERSION ********"
    # uv python install $DEPLOYED_PYTHON_VERSION

    if [ ! -d $LIBRARY_BASE_PATH/.venv ]; then
        echo "******** Creating virtual environment using uv with python$DEPLOYED_PYTHON_VERSION ********"
        uv venv --python python$DEPLOYED_PYTHON_VERSION
    fi
fi