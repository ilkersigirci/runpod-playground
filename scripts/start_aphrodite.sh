#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torch torchaudio torchvision -y
fi

if ! pip show aphrodite-engine >/dev/null 2>&1; then
    pip install aphrodite-engine
fi

# python -m aphrodite.endpoints.openai.api_server --help
MODEL=/workspace/models/Mixtral-8x7B-Instruct-v0.1 && \
MODEL_NAME=Mixtral-8x7B-Instruct-v0.1 && \
HF_HOME=/workspace/huggingface \
    python -m aphrodite.endpoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.9 \
    --model $MODEL \
    --served-model-name $MODEL_NAME