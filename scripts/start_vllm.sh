#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torch torchaudio torchvision -y
fi

if ! pip show vllm >/dev/null 2>&1; then
    echo "******** Installing vllm ********"
    pip install vllm==0.4.0.post1
    # Alternative: From github main
    # pip install git+https://github.com/vllm-project/vllm#main
fi

if ! pip show flash-attn >/dev/null 2>&1; then
    echo "******** Installing flash-attn ********"
    pip install flash-attn --no-build-isolation
fi

GPU_COUNT=$(nvidia-smi --query-gpu=count --format=csv,noheader,nounits | head -n 1)
# MODEL=/workspace/runpod-playground/models/Mixtral-8x7B-Instruct-v0.1
# MODEL_NAME=Mixtral-8x7B-Instruct-v0.1
# MODEL=/workspace/runpod-playground/models/c4ai-command-r-plus
# MODEL_NAME=c4ai-command-r-plus
MODEL=/workspace/runpod-playground/models/WizardLM-2-8x22B
MODEL_NAME=WizardLM-2-8x22B
HF_HOME=/workspace/huggingface \
    python -m vllm.entrypoints.openai.api_server \
    --host 0.0.0.0 \
    --port 8000 \
    --tensor-parallel-size $GPU_COUNT \
    --gpu-memory-utilization 0.9 \
    --enable-prefix-caching \
    --max-model-len 6000 \
    --model $MODEL \
    --served-model-name $MODEL_NAME