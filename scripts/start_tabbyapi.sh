#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torch torchaudio torchvision -y
fi

# Symbolic link models
for file in /workspace/runpod-playground/models/*; do
    ln -s "$file" "/workspace/tabbyAPI/official-repo/models/$(basename "$file")"
done

if ! pip show exllamav2 >/dev/null 2>&1; then
    pip install -r /workspace/tabbyAPI/official-repo/requirements.txt
fi

cd /workspace/tabbyAPI/official-repo && python3 main.py