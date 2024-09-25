#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

source ${LIBRARY_BASE_PATH}/scripts/send_teams_message.sh
source ${LIBRARY_BASE_PATH}/scripts/send_api_chat_message.sh

if [ "$ENABLE_HEALTH_CHECK" = "0" ]; then
    echo "HEALTH CHECK IS DISABLED."
    exit 1
fi

response=$(send_health_check_message)

for i in {1..3}; do
    if [ "$response" -eq 200 ]; then
        break
    fi
    echo "Attempt $i: Waiting for health endpoint to be available..."
    sleep 10
    response=$(send_health_check_message)
done

RESPONSE=$(send_guided_regex_message)

# Check if the curl command timed out
if echo "$RESPONSE" | grep -q "Request timed out."; then
    if [ "$ENABLE_AUTO_RESTART" = "1" ]; then
        pkill -f vllm.entrypoints
        nohup bash ${LIBRARY_BASE_PATH}/scripts/start_vllm.sh > vllm_log.txt 2>&1 &
    fi

    # Send message to Teams Chat
    MESSAGE="Request timed out. Hence, the model api is restarted."
    TITLE="${TEAMS_MESSAGE_TITLE} - POD FAILURE"

    if [ "$ENABLE_TEAMS_NOTIFICATION" = "1" ]; then
        send_teams_message "$TEAMS_WEBHOOK_URL" "$MESSAGE" "$TITLE"
    fi

    exit 1
fi

# Check if the response contains "200 OK"
if echo "$RESPONSE" | grep -q "200 OK"; then
    echo "Success: API responded with 200 OK."
    exit 0
fi

echo "API response did not contain '200 OK'."

if [ "$ENABLE_AUTO_RESTART" = "1" ]; then
    pkill -f vllm.entrypoints
    nohup bash ${LIBRARY_BASE_PATH}/scripts/start_vllm.sh > vllm_log.txt 2>&1 &
fi

# Send message to Teams Chat
MESSAGE="The model didn't correctly respond. Hence, the model api is restarted."
TITLE="${TEAMS_MESSAGE_TITLE} - POD FAILURE"

if [ "$ENABLE_TEAMS_NOTIFICATION" = "1" ]; then
    send_teams_message "$TEAMS_WEBHOOK_URL" "$MESSAGE" "$TITLE"
fi
