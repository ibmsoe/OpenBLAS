# This Dockerfile specifies the recipe for creating an image for the tests
# to run in.
#
# We install as many test dependencies here as we can, because these setup
# steps can be cached.  They do *not* run every time we run the build.
# The Docker image is only rebuilt when the Dockerfile (ie. this file)
# changes.

# Base Dockerfile for gRPC dev images
FROM ppc64le/ubuntu:latest

# Install dependencies.  We start with the basic ones require to build OpenBLAS
RUN apt-get update && apt-get install -y \
  autoconf \
  autotools-dev \
  build-essential \
  bzip2 \
  ccache \
  curl \
  gcc \
  g++ \
  git \
  gfortran \
  libc6 \
  libc6-dbg \
  libc6-dev \
  libtool \
  make \
  cmake \
  time \
  wget \
  debhelper \
  unzip \
  && apt-get clean


##################
# IBM MASS library consists of a set of mathematical functions for C, C++, and 
# Fortran-language applications that are tuned for optimum performance on
# POWER architectures. 
##################

RUN wget -q http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/public.gpg -O- | apt-key add

RUN echo "deb http://public.dhe.ibm.com/software/server/POWER/Linux/xl-compiler/eval/ppc64le/ubuntu/ trusty main" | tee /etc/apt/sources.list.d/ibm-xl-compiler-eval.list 

RUN apt-get update && apt-get install -y libxlmass-devel.8.1.3


##################
# Prepare ccache

RUN ln -s /usr/bin/ccache /usr/local/bin/gcc
RUN ln -s /usr/bin/ccache /usr/local/bin/g++
RUN ln -s /usr/bin/ccache /usr/local/bin/cc
RUN ln -s /usr/bin/ccache /usr/local/bin/c++
RUN ln -s /usr/bin/ccache /usr/local/bin/clang
RUN ln -s /usr/bin/ccache /usr/local/bin/clang++

# Define the default command.
CMD ["bash"]
