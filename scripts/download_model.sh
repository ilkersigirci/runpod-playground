#!/bin/bash

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

if [ ! $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME ]; then
    echo "******** $SERVED_MODEL_NAME already downloaded ********"
    exit 0
fi

echo "******** Installing download dependencies ********"
uv pip install python-dotenv huggingface-hub[cli] hf_transfer modelscope
echo "******** Downloading model ********"
huggingface-cli download $DEPLOYED_MODEL_NAME --repo-type model --revision main --local-dir $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME