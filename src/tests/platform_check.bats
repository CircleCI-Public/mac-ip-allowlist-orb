#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "1: platform_check - valid platform" {
  stub uname 'echo "Darwin"'

  run ./src/scripts/platform_check.sh

  assert_success
}

@test "2: platform_check - invalid platform" {
  stub uname 'echo "Linux"'

  run ./src/scripts/platform_check.sh

  assert_failure
}
