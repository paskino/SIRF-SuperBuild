#!/usr/bin/env bash
set -ev
# Gadgetron
# from https://github.com/gadgetron/gadgetron/blob/master/docker/base/ubuntu_1804/Dockerfile#L8
apt-get update -qq
apt-get install -yq --no-install-recommends \
  libhdf5-serial-dev     \
  libboost-all-dev       \
  libfftw3-dev           \
  h5utils                \
  jq                     \
  hdf5-tools             \
  libatlas-base-dev      \
  libxml2-dev            \
  libfreetype6-dev       \
  libxslt-dev            \
  libarmadillo-dev       \
  libace-dev             \
  liblapack-dev          \
  liblapacke-dev         \
  libplplot-dev          \
  libdcmtk-dev
apt-get clean
