#!/usr/bin/env bash
{
l_output=""
# Check the permissions, owner, and group of /etc/shells
l_stat_output=$(stat -Lc 'Access: (%#a/%A) Uid: (%u/%U) Gid: (%g/%G)' /etc/shells)

# Verify if permissions are correct (644 or more restrictive)
if [[ ! "$l_stat_output" =~ "Access: (0644/-rw-r--r--)" ]]; then
    l_output2="$l_output2\n - /etc/shells permissions are incorrect: $l_stat_output"
else
    l_output="$l_output\n - /etc/shells permissions are correct"
fi

# Verify if the owner and group are root
if [[ ! "$l_stat_output" =~ "Uid: ( 0/ root)" || ! "$l_stat_output" =~ "Gid: ( 0/ root)" ]]; then
    l_output2="$l_output2\n - /etc/shells owner or group is incorrect: $l_stat_output"
else
    l_output="$l_output\n - /etc/shells owner and group are correct"
fi

# Output the results
if [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n ** PASS **\n - Correctly configured: $l_output"
else
    echo -e "\n- Audit Result:\n ** FAIL **\n - Reasons for audit failure: $l_output2\n"
    [ -n "$l_output" ] && echo -e "\n - Correctly configured: $l_output\n"
fi

# Clean up
unset l_output l_output2 l_stat_output
}
