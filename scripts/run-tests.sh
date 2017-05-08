#!/usr/bin/env bash

if [ "$CMS_BUILDER_DOCKER" != "1" ]; then
  echo "Error: This script should only be run from inside the cms-builder docker container" >&2
  exit 1
fi

cd "$PROJECT_ROOT"

# Clone the repo.
if [ ! -z "$REPO_BRANCH" ]; then
  clone_options="--branch $REPO_BRANCH"
fi
git clone $clone_options "$REPO_URL" .

# Build the site and run the tests.
if [ -d /opt/cms-builder ]; then
  echo "Using custom cms-builder"
  cms_builder='/opt/cms-builder/cms-builder'
else
  cms_builder=cms-builder
fi
$cms_builder build $CMS_BUILDER_DEFAULT_SITE && \
  composer run-script behat-tests

# Bring down the site.
$cms_builder docker:stop