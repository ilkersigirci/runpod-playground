#!/bin/bash

if ! command -v nano >/dev/null 2>&1; then
    apt update -y && apt install nano htop nvtop ncdu -y
fi

if pip show torch | grep -q "Version: 2.1.1"; then
    pip uninstall torch torchaudio torchvision -y
fi

cd /workspace/runpod-playground/tabbyAPI
git clone https://github.com/theroyallab/tabbyAPI official-repo


# Symbolic link config
ln -s /workspace/runpod-playground/tabbyAPI/config.yml /workspace/runpod-playground/tabbyAPI/official-repo/config.yml

## Sample Overrides
ln -s /workspace/runpod-playground/tabbyAPI/sample_overrides.yml /workspace/runpod-playground/tabbyAPI/official-repo/sampler_overrides/sample_overrides.yml

# Symbolic link Models
for file in /workspace/runpod-playground/models/*; do
    ln -s "$file" "/workspace/runpod-playground/tabbyAPI/official-repo/models/$(basename "$file")"
done

## Symbolic link Prompts
for file in /workspace/runpod-playground/tabbyAPI/prompt_templates/*; do
    ln -s "$file" "/workspace/runpod-playground/tabbyAPI/official-repo/templates/$(basename "$file")"
done

if ! pip show exllamav2 >/dev/null 2>&1; then
    pip install -r /workspace/runpod-playground/tabbyAPI/official-repo/requirements.txt
fi

cd /workspace/runpod-playground/tabbyAPI/official-repo && python3 main.py