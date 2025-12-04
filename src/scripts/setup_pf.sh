#!/usr/bin/env bash

if [[ ! -f "$PARAM_PASSLIST" ]]; then
  echo "Error: PARAM_PASSLIST file does not exist: $PARAM_PASSLIST"
  exit 1
fi

echo "Creating firewall directory"
sudo mkdir -p /opt/circleci/firewall

echo "Creating pf tables"
sudo tee /opt/circleci/firewall/pf.tables >/dev/null <<EOF
table <passlist> persist file '$PARAM_PASSLIST'
table <blocklist> persist { 0.0.0.0/0 }
EOF

echo "Creating passlist anchors"
sudo tee /opt/circleci/firewall/pf.passlist >/dev/null <<EOF
pass in quick from <passlist> user { $PARAM_USERNAME }
pass out quick to <passlist> user { $PARAM_USERNAME }
EOF

echo "Creating DNS Anchors"
sudo tee /opt/circleci/firewall/pf.dns >/dev/null <<EOF
dns_server = "192.168.64.1"
pass out log quick inet proto { tcp udp } from any to \$dns_server port domain
EOF

echo "Creating Blocklist Anchors"
sudo tee /opt/circleci/firewall/pf.blocklist >/dev/null <<EOF
block in quick from <blocklist> user { $PARAM_USERNAME }
block out quick from <blocklist> user { $PARAM_USERNAME }
EOF

echo "Creating pf configuration file"
sudo tee /opt/circleci/firewall/pf.conf >/dev/null <<EOF
set limit table-entries 300000
set block-policy drop
set skip on lo0
scrub-anchor "com.apple/*"

include '/opt/circleci/firewall/pf.tables'

anchor 'circleci.passlist' label "Pass List"
load anchor 'circleci.passlist' from '/opt/circleci/firewall/pf.passlist'

anchor 'circleci.dns' label "DNS Anchor"
load anchor 'circleci.dns'  from '/opt/circleci/firewall/pf.dns'

anchor 'circleci.blocklist' label "Block List"
load anchor 'circleci.blocklist' from '/opt/circleci/firewall/pf.blocklist'
EOF

echo "Bare PF configuration created"

