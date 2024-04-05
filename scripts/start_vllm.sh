#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torch torchaudio torchvision -y
fi

if ! pip show vllm >/dev/null 2>&1; then
    pip install vllm==0.4.0
    
    # Alternative: From github main
    # pip install git+https://github.com/vllm-project/vllm#main
fi

if ! pip show flash-attn >/dev/null 2>&1; then
    pip install flash-attn --no-build-isolation

MODEL=/workspace/runpod-playground/models/Mixtral-8x7B-Instruct-v0.1 && \
MODEL_NAME=Mixtral-8x7B-Instruct-v0.1 && \
# MODEL=/workspace/runpod-playground/models/c4ai-command-r-plus && \
# MODEL_NAME=c4ai-command-r-plus && \
HF_HOME=/workspace/huggingface \
    python -m vllm.entrypoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.9 \
    --enable-prefix-caching \
    --model $MODEL \
    --served-model-name $MODEL_NAME
