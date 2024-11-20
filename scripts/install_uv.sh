#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

cd $LIBRARY_BASE_PATH

# Install uv
if ! command -v uv >/dev/null 2>&1; then
    echo "******** Installing uv ********"
    curl -LsSf https://astral.sh/uv/install.sh | sh
    
    source $HOME/.local/bin/env bash

    if [ ! -d $LIBRARY_BASE_PATH/.venv ]; then
        echo "******** Creating virtual environment using uv with python$DEPLOYED_PYTHON_VERSION ********"
        uv venv --python python$DEPLOYED_PYTHON_VERSION
    fi
fi