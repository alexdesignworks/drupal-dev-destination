#!/usr/bin/env bats
#
# Test demo installation.
#

load _helper
load _helper_drupaldev

@test "Demo auto discovery - enabled" {
  enable_demo_db

  assert_file_not_exists .data/db.sql

  run_install
  assert_files_present
  assert_git_repo

  assert_file_contains ".ahoy.yml" "DEMO_DB"
  assert_file_contains ".lagoon.yml" "DEMO_DB"
  assert_file_exists .data/db.sql
}

@test "Demo auto discovery - disabled" {
  enable_demo_db

  mktouch .data/db.sql
  assert_file_exists .data/db.sql

  run_install
  assert_files_present
  assert_git_repo

  assert_file_not_contains ".ahoy.yml" "DEMO_DB"
  assert_file_not_contains ".lagoon.yml" "DEMO_DB"
  assert_file_exists .data/db.sql

  contents=$(cat .data/db.sql)
  assert_empty "${contents}"
}

@test "Demo force disabled" {
  enable_demo_db
  export DRUPALDEV_DEMO=0

  assert_file_not_exists .data/db.sql

  run_install
  assert_files_present
  assert_git_repo

  assert_file_not_contains ".ahoy.yml" "DEMO_DB"
  assert_file_not_contains ".lagoon.yml" "DEMO_DB"
  assert_file_not_exists .data/db.sql
}

@test "Demo force enabled" {
  enable_demo_db
  export DRUPALDEV_DEMO=1

  mktouch .data/db.sql
  assert_file_exists .data/db.sql

  run_install
  assert_files_present
  assert_git_repo

  assert_file_contains ".ahoy.yml" "DEMO_DB"
  assert_file_contains ".lagoon.yml" "DEMO_DB"
  assert_file_exists .data/db.sql

  contents=$(cat .data/db.sql)
  assert_not_empty "${contents}"
}

@test "Demo auto discovery - enabled; skip demo processing" {
  enable_demo_db
  echo "DRUPALDEV_SKIP_DEMO=1">> .env

  assert_file_not_exists .data/db.sql

  run_install
  assert_files_present
  assert_git_repo

  assert_file_contains ".ahoy.yml" "DEMO_DB"
  assert_file_contains ".lagoon.yml" "DEMO_DB"
  assert_file_not_exists .data/db.sql
}
