#!/usr/bin/env bash

set -e
set -o pipefail

sudo -u "$PARAM_USERNAME" -H -E bash -l <<EOF
$PARAM_COMMAND
EOF
