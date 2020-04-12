#!/usr/bin/env bats
#
# DB-driven workflow.
#
# Due to test speed efficiency, all assertions ran withing a single test.

load _helper
load _helper_drevops
load _helper_drevops_workflow
#
#@test "Workflow: fresh install automatically discovered if database does not exist" {
#  rm -f .data/db.sql
#  export DREVOPS_SKIP_DEMO=1
#  assert_file_not_exists .data/db.sql
#
#  prepare_sut "Starting fresh install WORKFLOW tests for Drupal ${DRUPAL_VERSION} in build directory ${BUILD_DIR}"
#  # Assert that the database was not downloaded because DREVOPS_SKIP_DEMO was set.
#  assert_file_not_exists .data/db.sql
#
#  assert_ahoy_build
#  assert_gitignore
#
#  assert_ahoy_cli
#
#  assert_ahoy_drush
#
#  assert_ahoy_info
#
#  assert_ahoy_docker_logs
#
#  assert_ahoy_login
#
#  assert_ahoy_export_db
#
#  assert_ahoy_lint
#
#  assert_ahoy_test_unit
#
#  assert_ahoy_test_bdd
#
#  assert_ahoy_fe
#
#  assert_export_on_install_site
#
#  assert_ahoy_debug
#
#  assert_ahoy_clean
#
#  assert_ahoy_reset
#}
#
#@test "Workflow: download from image, storage in docker image" {
#  # Do not use demo database - testing demo database discovery is another test.
#  export DREVOPS_SKIP_DEMO=1
#
#  export DATABASE_DOWNLOAD_SOURCE=docker_registry
#  # @todo: Replace with test image. This demo image should be used only for
#  # demos.
#  export DATABASE_IMAGE=drevops/drevops-mariadb-drupal-data-demo-7.x
#  # Explicitly specify that we do not want to login into the public registry
#  # to use test image.
#  export DOCKER_REGISTRY_USERNAME=
#  export DOCKER_REGISTRY_TOKEN=
#
#  # @todo:d Remove
#  export VERBOSE_BUILD=1
#
#  # Make sure that demo database will not be downloaded.
#  rm -f .data/db.sql
#  assert_file_not_exists .data/db.sql
#
#  prepare_sut "Starting download from image, storage in docker image WORKFLOW tests for Drupal ${DRUPAL_VERSION} in build directory ${BUILD_DIR}"
#  # Assert that the database was not downloaded because DREVOPS_SKIP_DEMO was set.
#  assert_file_not_exists .data/db.sql
#
#  assert_file_contains ".env" "DATABASE_DOWNLOAD_SOURCE=docker_registry"
#  assert_file_contains ".env" "DATABASE_IMAGE=drevops/drevops-mariadb-drupal-data-demo-7.x"
#  assert_file_not_contains ".env" "CURL_DB_URL="
#
#  assert_ahoy_build
#
#  # Assert that DB reload would revert the content.
#  assert_reload_db
#
#  # Other stack asserts.
#  assert_gitignore
#
#  assert_ahoy_cli
#
#  assert_ahoy_drush
#
#  assert_ahoy_info
#
#  assert_ahoy_docker_logs
#
#  assert_ahoy_login
#
#  assert_ahoy_lint
#
#  assert_ahoy_test_unit
#
#  assert_ahoy_test_bdd
#
#  assert_ahoy_fe
#
#  assert_ahoy_debug
#
#  assert_ahoy_export_db "mydb.tar"
#
#  assert_ahoy_clean
#
#  assert_ahoy_reset
#}

@test "Workflow: download from image, storage in docker image, use cached image" {
  # Do not use demo database - testing demo database discovery is another test.
  export DREVOPS_SKIP_DEMO=1

  export DATABASE_DOWNLOAD_SOURCE=docker_registry
  # @todo: Replace with test image. This demo image should be used only for
  # demos.
  export DATABASE_IMAGE=drevops/drevops-mariadb-drupal-data-demo-7.x
  # Explicitly specify that we do not want to login into the public registry
  # to use test image.
  export DOCKER_REGISTRY_USERNAME=
  export DOCKER_REGISTRY_TOKEN=

  # @todo:d Remove
  export VERBOSE_BUILD=1

  # Make sure that demo database will not be downloaded.
  rm -f .data/db.sql
  assert_file_not_exists .data/db.sql

  prepare_sut "Starting download from image, storage in docker image WORKFLOW tests for Drupal ${DRUPAL_VERSION} in build directory ${BUILD_DIR}"
  # Assert that the database was not downloaded because DREVOPS_SKIP_DEMO was set.
  assert_file_not_exists .data/db.sql

  assert_file_contains ".env" "DATABASE_DOWNLOAD_SOURCE=docker_registry"
  assert_file_contains ".env" "DATABASE_IMAGE=drevops/drevops-mariadb-drupal-data-demo-7.x"
  assert_file_not_contains ".env" "CURL_DB_URL="

  assert_ahoy_build

  step "Check that DB loaded from cached image"

  # Remove any previously downloaded DB dumps.
  rm -Rf .data/db.tar
  assert_file_not_exists .data/db.tar

  # Make a change to current site, export the DB image, remove existing DB image
  # and rebuild the stack - the used image should have the expected changes.
  #
  # Assert that used DB image has content.
  assert_page_contains "/" "First test node"
  assert_page_contains "/" "Username"
  # Change homepage content and assert that the change was applied.
  ahoy drush vset site_frontpage user
  assert_page_not_contains "/" "First test node"
  assert_page_contains "/" "Username"
  # Export DB image.
  ahoy export-db "db.tar"
  assert_file_exists .data/db.tar

  # Remove existing image and assert that exported image still exists.
  ahoy clean
  docker image ls | grep -q "${DATABASE_IMAGE}"
  docker image rm "${DATABASE_IMAGE}"
  docker image ls | grep -q -v "${DATABASE_IMAGE}"
  assert_file_exists .data/db.tar

  # Run build.
  assert_ahoy_build

  # Assert that the contents of the DB was loaded from the
  assert_page_not_contains "/" "First test node"
  assert_page_contains "/" "Username"
}
