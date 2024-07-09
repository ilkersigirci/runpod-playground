#!/bin/bash

#########
# NOTE: Runpod doesn't have cron enabled. Hence, this script can't be used in Runpod.
#########

# Load .env file
source /workspace/runpod-playground/.env

# Define the full path to your script
SCRIPT_PATH="$1"

# Define the frequency of execution (default every 5 minutes)
SCHEDULE="$2"

if [ -z "$SCHEDULE" ]; then
    SCHEDULE="*/5 * * * *"
fi

# Temporary file to hold crontab contents
TEMP_CRONTAB=$(mktemp)

# Ensure the script is executable
chmod +x "$SCRIPT_PATH"

# Save current crontab to the temporary file
crontab -l > "$TEMP_CRONTAB"

# Check if the script is already scheduled to avoid duplicates
if ! grep -qF -- "$SCRIPT_PATH" "$TEMP_CRONTAB"; then
    # Append new cron job for the script
    echo "$SCHEDULE $SCRIPT_PATH >> $LIBRARY_BASE_PATH/logfile.log 2>&1" >> "$TEMP_CRONTAB"
    
    # Install new crontab from the temporary file
    crontab "$TEMP_CRONTAB"
    echo "Healthcheck script added to crontab."
else
    echo "Script is already scheduled in crontab."
fi

# Clean up
rm "$TEMP_CRONTAB"