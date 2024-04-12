#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torch torchaudio torchvision -y
fi


if ! pip show aphrodite-engine >/dev/null 2>&1; then
    # pip install aphrodite-engine==0.5.2
    curl -LR https://github.com/PygmalionAI/aphrodite-engine/releases/download/v0.5.2/aphrodite_engine-0.5.2-cp310-cp310-manylinux1_x86_64.whl --output "aphrodite_engine-0.5.2-cp310-cp310-manylinux1_x86_64.whl"
    pip install aphrodite_engine-0.5.2-cp310-cp310-manylinux1_x86_64.whl
fi

# python -m aphrodite.endpoints.openai.api_server --help
MODEL=/workspace/runpod-playground/models/Mixtral-8x7B-Instruct-v0.1 && \
MODEL_NAME=Mixtral-8x7B-Instruct-v0.1 && \
# MODEL=/workspace/runpod-playground/models/c4ai-command-r-v01 && \
# MODEL_NAME=c4ai-command-r-v01 && \
HF_HOME=/workspace/huggingface \
    python -m aphrodite.endpoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --tensor-parallel-size $(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | head -n 1) \
    --gpu-memory-utilization 0.9 \
    --model $MODEL \
    --served-model-name $MODEL_NAME