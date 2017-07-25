#!/bin/bash
#
# Builds docker image and runs a command under it.
# This is a generic script that is configured with the following variables:
#
# DOCKERFILE_DIR - Directory in which Dockerfile file is located.
# DOCKER_RUN_SCRIPT - Script to run under docker (relative to OpenBLAS repo root)
# OUTPUT_DIR - Directory that will be copied from inside docker after finishing.
# $@ - Extra args to pass to docker run


set -ex

cd $(dirname $0)/..
git_root=$(pwd)

# clone pkgbuild from internal git hub - key needed in build slave 
# into the same dir as OpenBLAS (git_root). The container will
# clone each repo into it's own space.

rm -rf pkgbuild
git clone $PKGBUILD_REMOTE
#cd -

# checkout pkgbuild commit level
cd pkgbuild
git checkout $PKGBUILD_COMMIT
cd $git_root

# Use image name based on Dockerfile location checksum
DOCKER_IMAGE_NAME=$(basename $DOCKERFILE_DIR)_$(sha1sum $DOCKERFILE_DIR/Dockerfile.powerai | cut -f1 -d\ )

# Make sure docker image has been built. Should be instantaneous if so.
docker build -t $DOCKER_IMAGE_NAME $DOCKERFILE_DIR

# Ensure existence of ccache directory
CCACHE_DIR=/tmp/openblas-ccache
mkdir -p $CCACHE_DIR

# Choose random name for docker container
CONTAINER_NAME="build_and_run_docker_$(uuidgen)"

# Run command inside docker
docker run \
  "$@" \
  -e CCACHE_DIR=$CCACHE_DIR \
  -e EXTERNAL_GIT_ROOT="/var/local/jenkins/openblas" \
  -e THIS_IS_REALLY_NEEDED='see https://github.com/docker/docker/issues/14203 for why docker is awful' \
  -v "$git_root:/var/local/jenkins/openblas:ro" \
  -v $CCACHE_DIR:$CCACHE_DIR \
  -w /var/local/git/openblas \
  --name=$CONTAINER_NAME \
  $DOCKER_IMAGE_NAME \
  bash -l "/var/local/jenkins/openblas/$DOCKER_RUN_SCRIPT" || FAILED="true"

# Copy output artifacts
if [ "$OUTPUT_DIR" != "" ]
then
  docker cp "$CONTAINER_NAME:/var/local/git/openblas/$OUTPUT_DIR" "$git_root" || FAILED="true"
fi

# remove the container, possibly killing it first
docker rm -f $CONTAINER_NAME || true

if [ "$FAILED" != "" ]
then
  exit 1
fi
