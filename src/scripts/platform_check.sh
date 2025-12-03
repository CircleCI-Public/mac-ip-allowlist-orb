#!/usr/bin/env bash

if [[ "$(uname)" != "Darwin" ]]; then
  echo "Error: This orb is only compatible with macOS executors. Platform detected: $(uname)"
  exit 1
fi
