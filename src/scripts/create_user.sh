#!/usr/bin/env bash

echo "Creating standard user..."

sudo sysadminctl -addUser "$PARAM_USERNAME" \
  -shell /bin/bash \
  -password "$(openssl rand -base64 16)"

echo "A user has been created with the username '$PARAM_USERNAME'"
