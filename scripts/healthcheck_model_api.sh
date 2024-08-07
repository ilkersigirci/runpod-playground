#!/bin/bash

# Load .env file
source /workspace/runpod-playground/.env

source ${LIBRARY_BASE_PATH}/scripts/send_teams_message.sh

# Check if API_ENDPOINT is set to "DUMMY"
if [ "$API_ENDPOINT" = "DUMMY" ]; then
    echo "Please set API_ENDPOINT."
    exit 1
fi

SERVED_MODEL_NAME="${DEPLOYED_MODEL_NAME#*/}"

RESPONSE=$(
curl --request POST \
    --silent \
    --max-time 30 \
    --url $API_ENDPOINT/v1/chat/completions \
    --header "Content-Type: application/json" \
    --data '{
  "model": "'"$SERVED_MODEL_NAME"'",
  "messages": [
  {
    "role": "user",
    "content": "Respond with 200 OK"
  }
  ], 
  "temperature": 0,
  "stream": false,
  "guided_regex": "200 OK"
}'
)

# Check if the curl command timed out
if [ $? -eq 28 ]; then
    echo "Request timed out."

    pkill -f vllm.entrypoints
    nohup bash ${LIBRARY_BASE_PATH}/scripts/start_vllm.sh > vllm_log.txt 2>&1 &

    # Send message to Teams Chat
    MESSAGE="Request timed out. Hence, the model api is restarted."
    TITLE="POD FAILURE"

    send_teams_message "$TEAMS_WEBHOOK_URL" "$MESSAGE" "$TITLE"

    exit 1
fi

# Check if the response contains "200 OK"
if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "Success: API responded with 200 OK."
    exit 0
fi

echo "API response did not contain '200 OK'."

pkill -f vllm.entrypoints
nohup bash ${LIBRARY_BASE_PATH}/scripts/start_vllm.sh > vllm_log.txt 2>&1 &

# Send message to Teams Chat
MESSAGE="The model didn't correctly respond. Hence, the model api is restarted."
TITLE="POD FAILURE"

send_teams_message "$TEAMS_WEBHOOK_URL" "$MESSAGE" "$TITLE"
