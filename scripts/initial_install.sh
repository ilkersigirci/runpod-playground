#!/bin/bash

# Load .env file
source /workspace/runpod-playground/.env

cd $LIBRARY_BASE_PATH

if ! command -v nano >/dev/null 2>&1; then
    echo "******** Installing apt dependencies ********"
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if [ ! -d $LIBRARY_BASE_PATH/.venv ]; then
    echo "******** Creating virtual environment using uv ********"
    bash $LIBRARY_BASE_PATH/scripts/install_uv.sh
fi

if ! uv pip show vllm >/dev/null 2>&1; then
    echo "******** Installing vllm and its required dependencies ********"
    uv sync --frozen
fi