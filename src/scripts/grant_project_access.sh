#!/usr/bin/env bash

# Check required variables before enabling strict mode (to provide friendly error messages)
if [[ -z "${CIRCLE_WORKING_DIRECTORY:-}" ]]; then
  echo "Error: CIRCLE_WORKING_DIRECTORY is not set"
  exit 1
fi

if [[ -z "${PARAM_USERNAME:-}" ]]; then
  echo "Error: PARAM_USERNAME is not set"
  exit 1
fi

set -euo pipefail

# Expand ~ if present (CircleCI uses ~/project as default)
WORK_DIR="${CIRCLE_WORKING_DIRECTORY/#\~/$HOME}"

if [[ ! -d "$WORK_DIR" ]]; then
  echo "Error: Project directory does not exist: $WORK_DIR"
  exit 1
fi

# Validate user exists before proceeding
if ! id "$PARAM_USERNAME" &>/dev/null; then
  echo "Error: User does not exist: $PARAM_USERNAME"
  exit 1
fi

GROUP_NAME="circleci-project"

echo "Creating shared group '$GROUP_NAME'..."
sudo dseditgroup -o create "$GROUP_NAME" 2>/dev/null || true

echo "Adding '$PARAM_USERNAME' to group '$GROUP_NAME'..."
sudo dseditgroup -o edit -a "$PARAM_USERNAME" -t user "$GROUP_NAME"

echo "Setting group ownership on project directory..."
sudo chgrp -R "$GROUP_NAME" "$WORK_DIR"

echo "Granting group read/write/execute access..."
sudo chmod -R g+rwX "$WORK_DIR"

echo "Access granted to $WORK_DIR via group '$GROUP_NAME'"
