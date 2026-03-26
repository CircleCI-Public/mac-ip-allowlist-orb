#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "Create user" {
  stub sudo \
    "sysadminctl -addUser \* \* \* \* \* : echo \$3 > ${BATS_TEST_TMPDIR}/created_user" \
    "git clone \* \* \* \* : true" \
    "chown -R \* \* : true" \
    "tee -a \* : cat > /dev/null" \
    "tee -a \* : cat > ${BATS_TEST_TMPDIR}/exported_functions"

  export PARAM_USERNAME="testuser"
  test_bats_function() { echo "hello from test"; }
  export -f test_bats_function

  run ./src/scripts/create_user.sh

  assert_success
  assert_output --partial "A user has been created with the username 'testuser'"
  assert_output --partial "Shell functions exported to 'testuser'"
  assert_file_contains "${BATS_TEST_TMPDIR}"/created_user $PARAM_USERNAME
  assert_file_contains "${BATS_TEST_TMPDIR}"/exported_functions "test_bats_function"

  unstub sudo
}
