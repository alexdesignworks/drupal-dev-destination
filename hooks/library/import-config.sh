#!/usr/bin/env bash
set -e
set -x
#
# Cloud Hook: cim
#
# Run drush cim in the target environment. This script works as
# any Cloud hook.

site="$1"
target_env="$2"

drush @$site.$target_env cim vcs --yes
