#!/bin/bash

# Function to send a message to a Microsoft Teams channel
send_teams_message() {
    local webhook_url="$1"
    local message="$2"
    local title="$3"
    local color="$4"

    # Check if webhook_url is DUMMY
    if [ "$webhook_url" = "DUMMY" ]; then
        return
    fi

    # Default color if not provided
    if [ -z "$color" ]; then
        color="0072C6"
    fi

    # Create the JSON payload
    payload=$(cat <<EOF
{
    "@type": "MessageCard",
    "@context": "http://schema.org/extensions",
    "themeColor": "$color",
    "summary": "$title",
    "sections": [{
        "activityTitle": "$title",
        "text": "$message"
    }]
}
EOF
)

    # Send the message using curl
    curl -H "Content-Type: application/json" -d "$payload" "$webhook_url"
}