#!/bin/bash

# Load .env file
source $(dirname "$(realpath "$0")")/../.env

if [ "$ENABLE_HEALTH_CHECK" = "0" ]; then
    echo "HEALTH CHECK IS DISABLED."
    exit 1
fi

# Define the full path to your script
SCRIPT_PATH="$1"

# Define the frequency of execution (default every 5 minutes)

# Ensure the script is executable
chmod +x "$SCRIPT_PATH"

# First wait for the specified delay before the first execution
sleep $HEALTHCHECK_INITIAL_TIME

# Infinite loop to run the script periodically
while true; do
  # Execute the script
  bash "$SCRIPT_PATH"
  
  # Wait for the specified delay before the next execution
  sleep $HEALTHCHECK_INTERVAL
done