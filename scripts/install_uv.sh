#!/bin/bash

cd /workspace/runpod-playground

# Install python3.11
if ! command -v python3.11 >/dev/null 2>&1; then
    add-apt-repository ppa:deadsnakes/ppa -y && apt update -y
    DEBIAN_FRONTEND=noninteractive TZ=Europe/Turkey apt install python3.11-full -y
fi

# Install uv
if ! command -v uv >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env bash

    if [ ! -d "/workspace/runpod-playground/.venv" ]; then
        uv venv --python python3.11
    fi
fi