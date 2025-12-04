#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "Create user" {
  stub sudo \
    "sysadminctl -addUser \* \* \* \* \* : echo \$3 > ${BATS_TEST_TMPDIR}/created_user"

  export PARAM_USERNAME="testuser"
  run ./src/scripts/create_user.sh

  assert_success
  assert_output --partial "A user has been created with the username 'testuser'"
  assert_file_contains "${BATS_TEST_TMPDIR}"/created_user $PARAM_USERNAME

  unstub sudo
}
