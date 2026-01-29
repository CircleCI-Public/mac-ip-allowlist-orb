#!/usr/bin/env bats

source ./src/tests/helpers/load_extensions.bash

@test "grant_project_access succeeds with valid directory" {
  stub id \
    "distiller-restricted : exit 0"
  stub sudo \
    "dseditgroup -o create \* : echo 'group created'" \
    "dseditgroup -o edit -a \* -t user \* : echo \$5 > ${BATS_TEST_TMPDIR}/added_user" \
    "chgrp -R \* \* : echo \$3 > ${BATS_TEST_TMPDIR}/chgrp_group; echo \$4 > ${BATS_TEST_TMPDIR}/chgrp_target" \
    "chmod -R g+rwX \* : echo \$4 > ${BATS_TEST_TMPDIR}/chmod_target"

  export CIRCLE_WORKING_DIRECTORY="${BATS_TEST_TMPDIR}"
  export HOME="${BATS_TEST_TMPDIR}"
  export PARAM_USERNAME="distiller-restricted"

  run ./src/scripts/grant_project_access.sh

  assert_success
  assert_output --partial "Creating shared group"
  assert_output --partial "Adding 'distiller-restricted' to group"
  assert_output --partial "Access granted to"
  assert_file_contains "${BATS_TEST_TMPDIR}"/added_user "distiller-restricted"
  assert_file_contains "${BATS_TEST_TMPDIR}"/chgrp_group "circleci-project"

  unstub id
  unstub sudo
}

@test "grant_project_access expands tilde in path" {
  mkdir -p "${BATS_TEST_TMPDIR}/project"

  stub id \
    "distiller-restricted : exit 0"
  stub sudo \
    "dseditgroup -o create \* : echo 'group created'" \
    "dseditgroup -o edit -a \* -t user \* : true" \
    "chgrp -R \* \* : echo \$4 > ${BATS_TEST_TMPDIR}/chgrp_target" \
    "chmod -R g+rwX \* : true"

  export CIRCLE_WORKING_DIRECTORY="~/project"
  export HOME="${BATS_TEST_TMPDIR}"
  export PARAM_USERNAME="distiller-restricted"

  run ./src/scripts/grant_project_access.sh

  assert_success
  assert_file_contains "${BATS_TEST_TMPDIR}"/chgrp_target "${BATS_TEST_TMPDIR}/project"

  unstub id
  unstub sudo
}

@test "grant_project_access fails when CIRCLE_WORKING_DIRECTORY not set" {
  unset CIRCLE_WORKING_DIRECTORY
  export PARAM_USERNAME="distiller-restricted"

  run ./src/scripts/grant_project_access.sh

  assert_failure
  assert_output --partial "CIRCLE_WORKING_DIRECTORY is not set"
}

@test "grant_project_access fails when PARAM_USERNAME not set" {
  export CIRCLE_WORKING_DIRECTORY="${BATS_TEST_TMPDIR}"
  unset PARAM_USERNAME

  run ./src/scripts/grant_project_access.sh

  assert_failure
  assert_output --partial "PARAM_USERNAME is not set"
}

@test "grant_project_access fails when directory does not exist" {
  export CIRCLE_WORKING_DIRECTORY="/nonexistent/path"
  export HOME="/tmp"
  export PARAM_USERNAME="distiller-restricted"

  run ./src/scripts/grant_project_access.sh

  assert_failure
  assert_output --partial "Project directory does not exist"
}

@test "grant_project_access fails when user does not exist" {
  stub id \
    "nonexistent-user : exit 1"

  export CIRCLE_WORKING_DIRECTORY="${BATS_TEST_TMPDIR}"
  export HOME="${BATS_TEST_TMPDIR}"
  export PARAM_USERNAME="nonexistent-user"

  run ./src/scripts/grant_project_access.sh

  assert_failure
  assert_output --partial "User does not exist: nonexistent-user"

  unstub id
}
