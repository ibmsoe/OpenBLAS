#!/bin/bash
#
# This is the script that runs inside Docker, once the image has been built,
# to execute all tests for the "pull request" project.

WORKSPACE_BASE=`pwd`
MY_DIR="$(dirname "$0")"
#TEST_SCRIPT=$MY_DIR/../tests.sh
#BUILD_DIR=/tmp/protobuf
PKG_DIR=/tmp/build

set -e  # exit immediately on error
set -x  # display all commands

# The pkgbuild repository is mounted into our Docker image, but read-only.
# We clone into a directory inside Docker (this is faster than cp).
rm -rf $PKG_DIR
mkdir -p $PKG_DIR
cd $PKG_DIR
git clone /var/local/jenkins/openblas/pkgbuild
cd $PKG_DIR/pkgbuild/openblas

# The openblas repository is mounted into our Docker image, but read-only.
# We clone into a directory inside Docker (this is faster than cp).
git clone /var/local/jenkins/openblas

# Set up the directory where our test output is going to go.
OUTPUT_DIR=`mktemp -d`
LOG_OUTPUT_DIR=$OUTPUT_DIR/logs
mkdir -p $LOG_OUTPUT_DIR/1/cpp

# Call into the package build code
$PKG_DIR/pkgbuild/openblas/pkgbuild_jenkins.sh

ls -l *.deb

# The directory that is copied from Docker back into the Jenkins workspace.
COPY_FROM_DOCKER=/var/local/git/openblas/testoutput
mkdir -p $COPY_FROM_DOCKER

# Process all the output files from "parallel" and package them into a single
# .xml file with detailed, broken-down test output.
cp *.deb $COPY_FROM_DOCKER

ls -l $COPY_FROM_DOCKER
