#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

send_health_check_message() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" "$API_ENDPOINT/health")

    echo "$response"
}

send_guided_regex_message() {
    local response=$(
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
    fi

    echo "$response"
}

send_message_without_system() {
    local response=$(
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
            "content": "Who are you?"
        }
        ], 
        "temperature": 0.8,
        "stream": false
        }'
    )

    # Check if the curl command timed out
    if [ $? -eq 28 ]; then
        echo "Request timed out."
    fi

    echo "$response"
}

send_message_with_system() {
    local response=$(
    curl --request POST \
        --silent \
        --max-time 30 \
        --url $API_ENDPOINT/v1/chat/completions \
        --header "Content-Type: application/json" \
        --data '{
        "model": "'"$SERVED_MODEL_NAME"'",
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
    )
    
    # Check if the curl command timed out
    if [ $? -eq 28 ]; then
        echo "Request timed out."
    fi

    echo "$response"
}

# Check if a function name is passed as an argument
if [ $# -eq 1 ]; then
    "$1"
fi