#!/bin/bash

if ! command -v nvtop >/dev/null 2>&1; then
    echo "******** Updating apt ********"
    apt update -y -qq > /dev/null
    echo "******** Installing useful deb packages ********"
    apt install nano htop nvtop ncdu -y -qq > /dev/null
fi

# Load .env file
source /workspace/runpod-playground/.env

# Create uv virtual environment
if [ ! -d $LIBRARY_BASE_PATH/.venv ]; then
    bash $LIBRARY_BASE_PATH/scripts/install_uv.sh
fi

# Load uv
source $HOME/.cargo/env bash

# Activate uv's virtual environment
source $LIBRARY_BASE_PATH/.venv/bin/activate

# Download model if not already present
SERVED_MODEL_NAME="${DEPLOYED_MODEL_NAME#*/}"
if [ ! -d $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME ]; then
    bash $LIBRARY_BASE_PATH/scripts/download_model.sh
fi

if ! uv pip show vllm >/dev/null 2>&1; then
    echo "******** Installing vllm and its required dependencies ********"
    uv pip install vllm==0.5.5 accelerate setuptools
    # Alternative: From github main
    # uv pip install git+https://github.com/vllm-project/vllm#main
fi

GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | head -n 1)
MODEL_PATH=$LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME

# --disable-sliding-window \
# --num-scheduler-steps 8 \
# --chat-template $LIBRARY_BASE_PATH/tabbyAPI/prompt_templates/codestral.jinja
python -m vllm.entrypoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-prefix-caching \
    --gpu-memory-utilization 0.97 \
    --use-v2-block-manager \
    --disable-log-stats \
    --tensor-parallel-size $GPU_COUNT \
    --max-model-len $MAX_CONTEXT_LEN \
    --model $MODEL_PATH \
    --served-model-name $SERVED_MODEL_NAME