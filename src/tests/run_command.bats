#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "run-command param handling" {
  stub sudo \
    "-u \* bash : cat > ${BATS_TEST_TMPDIR}/passed_input ; echo \$2 > ${BATS_TEST_TMPDIR}/user_arg"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="echo 'hello world'"

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_exists "${BATS_TEST_TMPDIR}"/passed_input
  assert_file_exists "${BATS_TEST_TMPDIR}"/user_arg

  assert_file_contains "${BATS_TEST_TMPDIR}"/passed_input "$PARAM_COMMAND"
  assert_file_contains "${BATS_TEST_TMPDIR}"/user_arg "$PARAM_USERNAME"

  unstub sudo
}
