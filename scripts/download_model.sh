#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

# Run the initial install script
bash $LIBRARY_BASE_PATH/scripts/initial_install.sh

# Load uv
source $HOME/.local/bin/env bash

# Activate uv's virtual environment
source $LIBRARY_BASE_PATH/.venv/bin/activate

# Download model if not already present
# SERVED_MODEL_NAME="${HF_MODEL_NAME#*/}"

if [ ! $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME ]; then
    echo "******** $SERVED_MODEL_NAME already downloaded ********"
    exit 0
fi

if ! uv pip show hf_transfer >/dev/null 2>&1; then
    echo "******** Installing download dependencies ********"
    uv pip install python-dotenv huggingface-hub[cli] hf_transfer modelscope
fi

echo "******** Downloading model ********"
huggingface-cli download $HF_MODEL_NAME --repo-type model --revision main --local-dir $LIBRARY_BASE_PATH/models/$SERVED_MODEL_NAME