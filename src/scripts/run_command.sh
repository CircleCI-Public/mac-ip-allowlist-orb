#!/usr/bin/env bash

set -e
set -o pipefail

# Use provided working directory, or fall back to CIRCLE_WORKING_DIRECTORY
WORK_DIR="${PARAM_WORKING_DIR:-$CIRCLE_WORKING_DIRECTORY}"

# Expand ~ if present (CircleCI uses ~/project as default)
WORK_DIR="${WORK_DIR/#\~/$HOME}"

if [[ -n "$WORK_DIR" ]]; then
  # Use arg-passing pattern to safely handle paths with special characters
  # -H sets HOME to target user's home directory
  # cd -- handles paths starting with -
  sudo -H -u "$PARAM_USERNAME" bash -c 'cd -- "$1" && eval "$2"' _ "$WORK_DIR" "$PARAM_COMMAND"
else
  sudo -H -u "$PARAM_USERNAME" bash <<EOF
$PARAM_COMMAND
EOF
fi
