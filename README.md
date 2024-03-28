# runpod-playground

## Steps

```bash
git clone https://github.com/ilkersigirci/runpod-playground.git

pip install -r requirements.lock

# Download model
HF_HOME=/workspace/runpod-playground/huggingface python /workspace/runpod-playground/download_model.py

# Start vllm
nohup bash /workspace/runpod-playground/scripts/start_vllm.sh > mixtral_vllm.txt &
```
