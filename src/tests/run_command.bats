#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "run-command param handling without working directory" {
  stub sudo \
    "-H -u \* bash : cat > ${BATS_TEST_TMPDIR}/passed_input ; echo \$3 > ${BATS_TEST_TMPDIR}/user_arg"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="echo 'hello world'"
  export PARAM_WORKING_DIR=""
  unset CIRCLE_WORKING_DIRECTORY

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_exists "${BATS_TEST_TMPDIR}"/passed_input
  assert_file_exists "${BATS_TEST_TMPDIR}"/user_arg

  assert_file_contains "${BATS_TEST_TMPDIR}"/passed_input "$PARAM_COMMAND"
  assert_file_contains "${BATS_TEST_TMPDIR}"/user_arg "$PARAM_USERNAME"

  unstub sudo
}

@test "run-command with CIRCLE_WORKING_DIRECTORY" {
  stub sudo \
    "-H -u \* bash -c \* _ \* \* : echo \$8 > ${BATS_TEST_TMPDIR}/work_dir ; echo \$9 > ${BATS_TEST_TMPDIR}/command"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="echo 'hello world'"
  export PARAM_WORKING_DIR=""
  export CIRCLE_WORKING_DIRECTORY="/Users/distiller/project"
  export HOME="/Users/distiller"

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_contains "${BATS_TEST_TMPDIR}"/work_dir "/Users/distiller/project"
  assert_file_contains "${BATS_TEST_TMPDIR}"/command "echo"

  unstub sudo
}

@test "run-command with explicit working_directory parameter" {
  stub sudo \
    "-H -u \* bash -c \* _ \* \* : echo \$8 > ${BATS_TEST_TMPDIR}/work_dir ; echo \$9 > ${BATS_TEST_TMPDIR}/command"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="npm install"
  export PARAM_WORKING_DIR="/custom/path"
  export CIRCLE_WORKING_DIRECTORY="/Users/distiller/project"
  export HOME="/Users/distiller"

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_contains "${BATS_TEST_TMPDIR}"/work_dir "/custom/path"
  assert_file_contains "${BATS_TEST_TMPDIR}"/command "npm"

  unstub sudo
}

@test "run-command expands tilde in working directory" {
  stub sudo \
    "-H -u \* bash -c \* _ \* \* : echo \$8 > ${BATS_TEST_TMPDIR}/work_dir"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="ls"
  export PARAM_WORKING_DIR=""
  export CIRCLE_WORKING_DIRECTORY="~/project"
  export HOME="/Users/distiller"

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_contains "${BATS_TEST_TMPDIR}"/work_dir "/Users/distiller/project"

  unstub sudo
}

@test "run-command handles working_directory with spaces" {
  stub sudo \
    "-H -u \* bash -c \* _ \* \* : echo \$8 > ${BATS_TEST_TMPDIR}/work_dir ; echo \$9 > ${BATS_TEST_TMPDIR}/command"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="echo test"
  export PARAM_WORKING_DIR="/path/with spaces/here"
  export HOME="/Users/distiller"

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_contains "${BATS_TEST_TMPDIR}"/work_dir "/path/with spaces/here"
  assert_file_contains "${BATS_TEST_TMPDIR}"/command "echo"

  unstub sudo
}

@test "run-command handles working_directory with single quotes" {
  stub sudo \
    "-H -u \* bash -c \* _ \* \* : echo \$8 > ${BATS_TEST_TMPDIR}/work_dir ; echo \$9 > ${BATS_TEST_TMPDIR}/command"

  export PARAM_USERNAME="circleci"
  export PARAM_COMMAND="echo test"
  export PARAM_WORKING_DIR="/path/with'quote/here"
  export HOME="/Users/distiller"

  run ./src/scripts/run_command.sh

  assert_success
  assert_file_contains "${BATS_TEST_TMPDIR}"/work_dir "/path/with'quote/here"
  assert_file_contains "${BATS_TEST_TMPDIR}"/command "echo"

  unstub sudo
}
