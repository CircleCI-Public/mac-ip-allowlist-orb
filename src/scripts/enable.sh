#!/usr/bin/env bash

pfctl_run() {
  sudo pfctl "$@" 2>&1 | awk '!/ALTQ/'
}

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
