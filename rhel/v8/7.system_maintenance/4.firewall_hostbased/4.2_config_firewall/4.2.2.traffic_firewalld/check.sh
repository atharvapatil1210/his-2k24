#!/usr/bin/env bash

l_output=""
l_output2=""
l_hbfw=""

# Check if firewalld is enabled
if systemctl is-enabled firewalld.service | grep -q 'enabled'; then
    echo -e "\n - FirewallD is in use on the system" && l_hbfw="fwd"
elif systemctl is-enabled nftables.service 2>/dev/null | grep -q 'enabled'; then
    echo -e "\n - nftables is in use on the system \n - Recommendation is NA" &&
    l_hbfw="nft"
else
    echo -e "\n - Error - Neither FirewallD nor NFTables is enabled\n - Please follow recommendation: \"Ensure a single firewall configuration utility is in use\""
fi

# Check if Firewalld is in use
if [ "$l_hbfw" = "fwd" ]; then
    # Check loopback interface configuration
    if nft list ruleset | awk '/hook\s+input\s+/,/\}\s*(#.*)?$/' | grep -Pq -- '\H+\h+"lo"\h+accept'; then
        l_output="$l_output\n - Network traffic to the loopback address is correctly set to accept"
    else
        l_output2="$l_output2\n - Network traffic to the loopback address is not set to accept"
    fi

    # Check IPv4 traffic drop rule for loopback
    l_ipsaddr="$(nft list ruleset | awk '/filter_IN_public_deny|hook\s+input\s+/,/\}\s*(#.*)?$/' | grep -P -- 'ip\h+saddr')"
    if grep -Pq -- 'ip\h+saddr\h+127\.0\.0\.0\/8\h+(counter\h+packets\h+\d+\h+bytes\h+\d+\h+)?drop' <<< "$l_ipsaddr" || grep -Pq -- 'ip\h+daddr\h+\!\=\h+127\.0\.0\.1\h+ip\h+saddr\h+127\.0\.0\.1\h+drop' <<< "$l_ipsaddr"; then
        l_output="$l_output\n - IPv4 network traffic from loopback address correctly set to drop"
    else
        l_output2="$l_output2\n - IPv4 network traffic from loopback address not set to drop"
    fi

    # Check IPv6 traffic drop rule for loopback
    if grep -Pq -- '^\h*0\h*$' /sys/module/ipv6/parameters/disable; then
        l_ip6saddr="$(nft list ruleset | awk '/filter_IN_public_deny|hook input/,/}/' | grep 'ip6 saddr')"
        if grep -Pq 'ip6\h+saddr\h+::1\h+(counter\h+packets\h+\d+\h+bytes\h+\d+\h+)?drop' <<< "$l_ip6saddr" || grep -Pq -- 'ip6\h+daddr\h+\!=\h+::1\h+ip6\h+saddr\h+::1\h+drop' <<< "$l_ip6saddr"; then
            l_output="$l_output\n - IPv6 network traffic from loopback address correctly set to drop"
        else
            l_output2="$l_output2\n - IPv6 network traffic from loopback address not set to drop"
        fi
    fi
fi

# Final audit result
if [ "$l_hbfw" = "nft" ] || [ -z "$l_output2" ]; then
    echo -e "\n- Audit Result:\n *** PASS ***\n$l_output"
else
    echo -e "\n- Audit Result:\n *** FAIL ***\n$l_output2\n\n - Correctly set:\n$l_output"
fi

