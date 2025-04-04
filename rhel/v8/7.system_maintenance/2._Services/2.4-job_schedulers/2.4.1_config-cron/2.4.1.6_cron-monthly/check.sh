#!/bin/bash

# Define expected permission and ownership values
expected_permissions="700"
expected_uid="0"
expected_gid="0"

# Check if cron is installed and /etc/cron.monthly directory exists
if command -v cron >/dev/null 2>&1 && [ -d /etc/cron.monthly ]; then
    # Get the current permissions, UID, and GID of /etc/cron.monthly
    dir_info=$(stat -Lc '%a %u %g' /etc/cron.monthly)
    current_permissions=$(echo "$dir_info" | awk '{print $1}')
    current_uid=$(echo "$dir_info" | awk '{print $2}')
    current_gid=$(echo "$dir_info" | awk '{print $3}')

    # Verify permissions
    if [ "$current_permissions" == "$expected_permissions" ] && [ "$current_uid" == "$expected_uid" ] && [ "$current_gid" == "$expected_gid" ]; then
        echo "PASS: /etc/cron.monthly has correct permissions and ownership."
    else
        echo "FAIL: /etc/cron.monthly does not have correct permissions or ownership."
        echo "Current permissions: $current_permissions, UID: $current_uid, GID: $current_gid"
        echo "Expected permissions: $expected_permissions, UID: $expected_uid, GID: $expected_gid"
    fi
else
    echo "cron is not installed or /etc/cron.monthly directory does not exist on this system."
fi

