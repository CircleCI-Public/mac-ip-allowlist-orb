#!/usr/bin/env bash

set -e
set -o pipefail

sudo -u "$PARAM_USERNAME" bash <<EOF
$PARAM_COMMAND
EOF
