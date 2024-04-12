# runpod-playground

## Steps

```bash
cd /workspace
git clone https://github.com/ilkersigirci/runpod-playground.git
cd /workspace/runpod-playground
pip install -r requirements.lock

# Download model
HF_HOME=/workspace/runpod-playground/huggingface python /workspace/runpod-playground/runpod_playground/download_model.py

# Start vllm
nohup bash /workspace/runpod-playground/scripts/start_vllm.sh > vllm_output.txt &
```

- Example request with system message

```bash
curl --request POST \
    --url https://1rvt8fq3evjipt-8000.proxy.runpod.net/v1/chat/completions \
    --header "Content-Type: application/json" \
    --data '{
  "model": "Mixtral-8x7B-Instruct-v0.1",
  "messages": [
  {
      "role": "system",
      "content": "You are a helpful virtual assistant trained by OpenAI."
  },
  {
    "role": "user",
    "content": "Who are you?"
  }
  ], 
  "temperature": 0.8,
  "stream": false
}'
```

- Example request without system message

```bash
curl --request POST \
    --url https://1rvt8fq3evjipt-8000.proxy.runpod.net/v1/chat/completions \
    --header "Content-Type: application/json" \
    --data '{
  "model": "Mixtral-8x7B-Instruct-v0.1",
  "messages": [
  {
    "role": "user",
    "content": "Who are you?"
  }
  ], 
  "temperature": 0.8,
  "stream": false
}'
```

## TabbyAPI Prompt Templates

- [Official tabbyAPI Templates](https://github.com/theroyallab/llm-prompt-templates/)
- [chat_templates github](https://github.com/chujiezheng/chat_templates)

## Model CLI Download

```bash
huggingface-cli download turboderp/Llama2-7B-chat-exl2 --revision 4.0bpw --local-dir-use-symlinks False --local-dir my_model_dir
```