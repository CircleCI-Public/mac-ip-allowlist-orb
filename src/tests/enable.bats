#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "test enable" {
  stub sudo \
    "pfctl -E -f \* : echo \$4 > ${BATS_TEST_TMPDIR}/enabled_config" \
    "exit 0" \
    "exit 0" \
    "exit 0" \
    "exit 0"

  run ./src/scripts/enable.sh

  assert_success
  assert_file_exists "${BATS_TEST_TMPDIR}"/enabled_config
  assert_file_contains "${BATS_TEST_TMPDIR}"/enabled_config "/opt/circleci/firewall/pf.conf"

  unstub sudo
}
