#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    echo "******** Installing useful deb packages ********"
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    echo "******** Uninstalling torch 2.1.1 ********"
    pip uninstall torch torchaudio torchvision -y
fi

if ! pip show huggingface_hub >/dev/null 2>&1; then
    echo "******** Installing project dependencies ********"
    pip install -r requirements.lock
fi

# Download model if not already present
SERVED_MODEL_NAME="${DEPLOYED_MODEL_NAME#*/}"

if [ ! -d $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME ]; then
    echo "******** Downloading model ********"
    python $LIBRARY_BASE_PATH/runpod_playground/download_model.py
fi


if ! pip show vllm >/dev/null 2>&1; then
    echo "******** Installing vllm ********"
    pip install vllm==0.4.2
    # Alternative: From github main
    # pip install git+https://github.com/vllm-project/vllm#main
fi

if ! pip show flash-attn >/dev/null 2>&1; then
    echo "******** Installing flash-attn ********"
    pip install flash-attn --no-build-isolation
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