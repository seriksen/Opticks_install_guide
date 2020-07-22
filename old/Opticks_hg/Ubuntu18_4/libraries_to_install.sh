#!/usr/bin/env bash
#
# This doesn't include ones required for Cuda or OptiX
# It is assumed that you already have these installed

apt-get install -y \
        mercurial \
        unzip \
        libxrandr-dev \
        libxinerama-dev \
        libxcursor-dev \
        libexpat1-dev \
        libssl-dev \
        libprotobuf-dev \
        libleveldb-dev \
        libsnappy-dev \
        libopencv-dev \
        libhdf5-serial-dev \
        libgflags-dev \
        libgoogle-glog-dev \
        liblmdb-dev \
        protobuf-compiler \
        libatlas-base-dev \
        python-dev \
        python-pip \
        gfortran \
        ipython

pip install \
        numpy \
        matplotlib


