#!/bin/bash

# Check if /etc/issue.net exists
if [ -e /etc/issue.net ]; then
    # Get file permissions, owner, and group
    PERMISSIONS=$(stat -c "%a" /etc/issue.net)
    OWNER=$(stat -c "%u" /etc/issue.net)
    GROUP=$(stat -c "%g" /etc/issue.net)

    # Display current settings
    echo "Current permissions: $PERMISSIONS"
    echo "Current owner: $OWNER"
    echo "Current group: $GROUP"

    # Check if permissions are 0644 and owner/group is root (UID/GID = 0)
    if [ "$PERMISSIONS" != "644" ]; then
        echo "Warning: Permissions on /etc/issue.net are not 0644"
    else
        echo "Permissions on /etc/issue.net are correct"
    fi

    if [ "$OWNER" != "0" ] || [ "$GROUP" != "0" ]; then
        echo "Warning: Owner or group of /etc/issue.net is not root"
    else
        echo "Owner and group of /etc/issue.net are correct"
    fi
else
    echo "/etc/issue.net does not exist."
fi
