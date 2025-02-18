#!/usr/bin/env bash

{
    echo "Checking xinetd package and its service..."

    # Check if xinetd package is installed
    if rpm -q xinetd > /dev/null 2>&1; then
        echo " - xinetd package is installed."

        # Check if xinetd.service is enabled
        if systemctl is-enabled xinetd.service 2>/dev/null | grep 'enabled' > /dev/null; then
            echo " - FAIL: xinetd.service is enabled."
        else
            echo " - PASS: xinetd.service is not enabled."
        fi

        # Check if xinetd.service is active
        if systemctl is-active xinetd.service 2>/dev/null | grep '^active' > /dev/null; then
            echo " - FAIL: xinetd.service is active."
        else
            echo " - PASS: xinetd.service is not active."
        fi
    else
        echo " - PASS: xinetd package is not installed."
    fi
}

