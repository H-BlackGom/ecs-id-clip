#!/usr/bin/env bats

load 'bats-support/load'
load 'bats-assert/load'

# Mock the aws config file
setup() {
  mkdir -p "$BATS_TMPDIR/home/.aws"
  cat > "$BATS_TMPDIR/home/.aws/config" <<EOF
[profile default]
region = us-east-1

[profile test-profile]
region = us-west-2
EOF
  export HOME="$BATS_TMPDIR/home"
}

teardown() {
  export HOME="$HOME"
}

@test "get_aws_profiles returns a list of profiles" {
  # shellcheck source=../src/lib/aws_helpers.sh
  source "src/lib/aws_helpers.sh"
  run get_aws_profiles
  assert_success
  assert_output --partial "default"
  assert_output --partial "test-profile"
}

@test "copy_to_clipboard copies text" {
  # shellcheck source=../src/lib/utils.sh
  source "src/lib/utils.sh"
  
  # This is a simple test to ensure the function runs without error.
  # It doesn't truly test the clipboard functionality in a CI environment.
  run copy_to_clipboard "hello"
  assert_success
}
