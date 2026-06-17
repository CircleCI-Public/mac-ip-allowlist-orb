#!/usr/bin/env bash

pfctl_run() {
  sudo pfctl "$@" 2>&1 | awk '!/ALTQ/'
}

printf "Disabling IPv6 on all network services...\n"

networksetup -listallnetworkservices | tail -n +2 | while IFS= read -r service; do
    networksetup -setv6off "$service" 2>/dev/null
done

printf "\nVerifying IPv6 has been disabled on all interfaces...\n"

networksetup -listallhardwareports | grep -A1 "^Hardware Port:" | grep "Device:" | awk '{print $2}' | while IFS= read -r device; do
    if ifconfig "$device" 2>/dev/null | grep -q inet6; then
        printf "WARNING: IPv6 still detected on %s\n" "$device"
    fi
done

printf "Enabling IP allow list\n"
pfctl_run -E -f /opt/circleci/firewall/pf.conf

printf "
---------
Passlist:
"
pfctl_run -s rules -a circleci.passlist

printf "
---------
DNS:
"
pfctl_run -s rules -a circleci.dns

printf "
---------
IPv6 Block:
"
pfctl_run -s rules -a circleci.ipv6block

printf "
---------
blocklist:
"
pfctl_run -s rules -a circleci.blocklist

printf "
---------
Allowed IPs:
"
pfctl_run -t passlist -T show

printf "
---------
Done!
"
