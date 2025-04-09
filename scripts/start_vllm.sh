#!/bin/bash

if ! command -v nvtop >/dev/null 2>&1; then
    echo "******** Updating apt ********"
    apt update -y -qq > /dev/null
    echo "******** Installing useful deb packages ********"
    apt install nano htop nvtop ncdu -y -qq > /dev/null
fi

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

# Run the initial install script
bash $LIBRARY_BASE_PATH/scripts/initial_install.sh

# Load uv
source $HOME/.local/bin/env bash

# Activate uv's virtual environment
source $LIBRARY_BASE_PATH/.venv/bin/activate

# Download model if not already present
if [ ! -d $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME ]; then
    bash $LIBRARY_BASE_PATH/scripts/download_model.sh
fi

# if ! uv pip show vllm >/dev/null 2>&1; then
#     echo "******** Installing vllm and its required dependencies ********"
#     uv pip install vllm==0.6.0 accelerate setuptools
#     # Alternative: From github main
#     # uv pip install git+https://github.com/vllm-project/vllm#main
# fi

GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | head -n 1)
MODEL_PATH=$LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME

# --disable-sliding-window \
# --num-scheduler-steps 8 \
# --enable-chunked-prefill \
# --chat-template $LIBRARY_BASE_PATH/prompt_templates/codestral.jinja
# --enable-auto-tool-choice \
# --tool-call-parser llama3_json

# python -m vllm.entrypoints.openai.api_server \
vllm serve $MODEL_PATH \
    --served-model-name $SERVED_MODEL_NAME \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-prefix-caching \
    --gpu-memory-utilization 0.90 \
    --disable-log-stats \
    --tensor-parallel-size $GPU_COUNT \
    --max-model-len $MAX_CONTEXT_LEN