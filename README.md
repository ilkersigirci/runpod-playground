# runpod-playground

## Steps

```bash
cd /workspace
git clone https://github.com/ilkersigirci/runpod-playground.git
cd /workspace/runpod-playground

# Download model
make download-model

# Start vllm
make start-vllm

# See vllm logs
make log-vllm

# Restart vllm
make restart-vllm
```

- To deploy different model, in `.env` file, change `DEPLOYED_MODEL_NAME` variable to the model name you want to deploy by following hunggingface repository id convention.
- One can also change `MAX_CONTEXT_LEN` variable to the desired context length.
- Example: Change default model and its context length to CohereForAI/c4ai-command-r-v01

```bash
make change-model-env DEPLOYED_MODEL_NAME=CohereForAI/c4ai-command-r-v01
make change-max-context-len-env MAX_CONTEXT_LEN=40000

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
huggingface-cli download microsoft/Phi-3-mini-128k-instruct --repo-type model --revision main --local-dir models/Phi-3-mini-128k-instruct
```
