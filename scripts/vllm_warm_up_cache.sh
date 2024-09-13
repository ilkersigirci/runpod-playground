#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

source ${LIBRARY_BASE_PATH}/scripts/send_api_chat_message.sh

response=$(send_health_check_message)

while [ "$response" -ne 200 ]; do
  echo "Waiting for health endpoint to be available..."
  sleep 10
  response=$(send_health_check_message)
done

# Send two message to the the vllm api
send_message_without_system
send_message_without_system