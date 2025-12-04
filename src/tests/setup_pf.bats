#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

setup() {
  touch /tmp/passlist
}

teardown() {
  sudo rm -rf /opt/circleci
}

@test "Errors when passlist file does not exist" {
  export PARAM_USERNAME="testuser"
  export PARAM_PASSLIST=/tmp/nonexistent_passlist
  run ./src/scripts/setup_pf.sh
  [ "$status" -ne 0 ]
}

@test "Setup pf firewall" {
  export PARAM_USERNAME="testuser"
  export PARAM_PASSLIST=/tmp/passlist
  run ./src/scripts/setup_pf.sh
  [ "$status" -eq 0 ]

  assert_dir_exists /opt/circleci
  assert_dir_exists /opt/circleci/firewall

  assert_file_exists /opt/circleci/firewall/pf.tables
  assert_file_exists /opt/circleci/firewall/pf.passlist
  assert_file_exists /opt/circleci/firewall/pf.dns
  assert_file_exists /opt/circleci/firewall/pf.conf

  assert_file_contains /opt/circleci/firewall/pf.passlist "pass in quick from <passlist> user { $PARAM_USERNAME }"
  assert_file_contains /opt/circleci/firewall/pf.passlist "pass out quick to <passlist> user { $PARAM_USERNAME }"
  assert_file_contains /opt/circleci/firewall/pf.blocklist "block in quick from <blocklist> user { $PARAM_USERNAME }"
  assert_file_contains /opt/circleci/firewall/pf.blocklist "block out quick from <blocklist> user { $PARAM_USERNAME }"
}

