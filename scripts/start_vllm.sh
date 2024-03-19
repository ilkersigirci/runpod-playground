#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torchaudio torchvision -y
fi

if ! pip show vllm >/dev/null 2>&1; then
    pip install vllm==0.3.3
fi

# --tensor-parallel-size 2
MODEL=/workspace/models/Mixtral-8x7B-Instruct-v0.1 && \
MODEL_NAME=Mixtral-8x7B-Instruct-v0.1 && \
# MODEL=/workspace/models/Trendyol-LLM-7b-chat-v0.1 && \
# MODEL_NAME=Trendyol && \
# MODEL=/workspace/models/aya-101&& \
# MODEL_NAME=Aya && \
HF_HOME=/workspace/huggingface \
    python -m vllm.entrypoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --tensor-parallel-size 2 \
    --gpu-memory-utilization 0.9 \
    --model $MODEL \
    --served-model-name $MODEL_NAME
