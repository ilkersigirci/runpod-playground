#!/bin/bash

# Load .env file
source /workspace/runpod-playground/.env

# Define the full path to your script
SCRIPT_PATH="$1"

# Define the frequency of execution (default every 5 minutes)
SCHEDULE="$2"

if [ -z "$SCHEDULE" ]; then
    SCHEDULE=300
fi

# Ensure the script is executable
chmod +x "$SCRIPT_PATH"

# First wait for the specified delay before the first execution
sleep $SCHEDULE

# Infinite loop to run the script periodically
while true; do
  # Execute the script
  bash "$SCRIPT_PATH"
  
  # Wait for the specified delay before the next execution
  sleep $SCHEDULE
done