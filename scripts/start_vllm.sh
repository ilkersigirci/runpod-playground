#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    echo "******** Installing useful deb packages ********"
    apt update -y && apt install nano htop nvtop ncdu -y
fi

# Create uv virtual environment
if [ ! -d "/workspace/runpod-playground/.venv" ]; then
    echo "******** Creating virtual environment using uv with python3.11 ********"
    bash /workspace/runpod-playground/scripts/install_uv.sh
fi

source $HOME/.cargo/env bash
source /workspace/runpod-playground/.venv/bin/activate

# Download model if not already present
SERVED_MODEL_NAME="${DEPLOYED_MODEL_NAME#*/}"

if [ ! -d $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME ]; then
    echo "******** Installing download dependencies ********"
    uv pip install python-dotenv huggingface-hub hf_transfer modelscope
    echo "******** Downloading model ********"
    python $LIBRARY_BASE_PATH/runpod_playground/download_model.py
fi


if ! uv pip show vllm >/dev/null 2>&1; then
    echo "******** Installing vllm and its required dependencies ********"
    uv pip install vllm==0.4.2 vllm-flash-attn==2.5.8.post1 accelerate
    # Alternative: From github main
    # uv pip install git+https://github.com/vllm-project/vllm#main
fi

GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | head -n 1)
MODEL_PATH=$LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME
HF_HOME=/workspace/huggingface \
    python -m vllm.entrypoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --enable-prefix-caching \
    --gpu-memory-utilization 0.97 \
    --tensor-parallel-size $GPU_COUNT \
    --max-model-len $MAX_CONTEXT_LEN \
    --model $MODEL_PATH \
    --served-model-name $SERVED_MODEL_NAME