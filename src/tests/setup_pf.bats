#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

setup() {
  export TEST_OPT_DIR="${BATS_TEST_TMPDIR}/opt/circleci/firewall"
  mkdir -p "$TEST_OPT_DIR"
  touch "${BATS_TEST_TMPDIR}/passlist"
}

@test "Errors when passlist file does not exist" {
  export PARAM_USERNAME="testuser"
  export PARAM_PASSLIST="${BATS_TEST_TMPDIR}/nonexistent_passlist"

  run ./src/scripts/setup_pf.sh

  assert_failure
  assert_output --partial "PARAM_PASSLIST file does not exist"
}

@test "Setup pf firewall" {
  export PARAM_USERNAME="testuser"
  export PARAM_PASSLIST="${BATS_TEST_TMPDIR}/passlist"

  # Stub sudo to redirect writes to our temp directory
  stub sudo \
    "mkdir -p /opt/circleci/firewall : mkdir -p ${TEST_OPT_DIR}" \
    "tee /opt/circleci/firewall/pf.tables : cat > ${TEST_OPT_DIR}/pf.tables" \
    "tee /opt/circleci/firewall/pf.passlist : cat > ${TEST_OPT_DIR}/pf.passlist" \
    "tee /opt/circleci/firewall/pf.dns : cat > ${TEST_OPT_DIR}/pf.dns" \
    "tee /opt/circleci/firewall/pf.blocklist : cat > ${TEST_OPT_DIR}/pf.blocklist" \
    "tee /opt/circleci/firewall/pf.conf : cat > ${TEST_OPT_DIR}/pf.conf"

  run ./src/scripts/setup_pf.sh

  assert_success

  assert_file_exists "${TEST_OPT_DIR}/pf.tables"
  assert_file_exists "${TEST_OPT_DIR}/pf.passlist"
  assert_file_exists "${TEST_OPT_DIR}/pf.dns"
  assert_file_exists "${TEST_OPT_DIR}/pf.blocklist"
  assert_file_exists "${TEST_OPT_DIR}/pf.conf"

  assert_file_contains "${TEST_OPT_DIR}/pf.passlist" "pass in quick from <passlist> user { testuser }"
  assert_file_contains "${TEST_OPT_DIR}/pf.passlist" "pass out quick to <passlist> user { testuser }"
  assert_file_contains "${TEST_OPT_DIR}/pf.blocklist" "block in quick from <blocklist> user { testuser }"
  assert_file_contains "${TEST_OPT_DIR}/pf.blocklist" "block out quick from <blocklist> user { testuser }"

  unstub sudo
}
