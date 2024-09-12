#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

source ${LIBRARY_BASE_PATH}/scripts/send_teams_message.sh
source ${LIBRARY_BASE_PATH}/scripts/send_api_chat_message.sh

if [ "$ENABLE_HEALTH_CHECK" = "0" ]; then
    echo "HEALTH CHECK IS DISABLED."
    exit 1
fi

RESPONSE=$(send_guided_regex_message)

# Check if the curl command timed out
if echo "$RESPONSE" | grep -q "Request timed out."; then
    pkill -f vllm.entrypoints
    nohup bash ${LIBRARY_BASE_PATH}/scripts/start_vllm.sh > vllm_log.txt 2>&1 &

    # Send message to Teams Chat
    MESSAGE="Request timed out. Hence, the model api is restarted."
    TITLE="${TEAMS_MESSAGE_TITLE} - POD FAILURE"

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
TITLE="${TEAMS_MESSAGE_TITLE} - POD FAILURE"

send_teams_message "$TEAMS_WEBHOOK_URL" "$MESSAGE" "$TITLE"
