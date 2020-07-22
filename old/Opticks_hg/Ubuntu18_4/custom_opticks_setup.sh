#!/usr/bin/env bash

# CUDA
export PATH=/usr/local/cuda-10.1/bin:/usr/local/cuda-10.1/NsightCompute-2019.1${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# NVidia OptiX
export LD_LIBRARY_PATH=/home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Interactions with Opticks
opticks-(){ . /home/ubuntu/opticks/opticks.bash && opticks-env $* ; }
opticks-

export LOCAL_BASE=/usr/local
export OPTICKS_HOME=/home/ubuntu/opticks
o(){ cd $(opticks-home) ; hg st ; }
op(){ op.sh $* ; }

export PYTHONPATH=/home/ubuntu:${PYTHONPATH}
export PATH=$LOCAL_BASE/opticks/lib:$OPTICKS_HOME/bin:$OPTICKS_HOME/ana:$PATH


# To install externals
opticks-cmake-generator(){ echo ${OPTICKS_CMAKE_GENERATOR:-Unix Makefiles} ; }

# For optixrap complitation
export OptiX_INSTALL_DIR=/home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64
export CXXFLAGS="$CXXFLAGS -fPIC"
export CFLAGS="$CFLAGS -fPIC"

# Set compute capability
export OPTICKS_COMPUTE_CAPABILITY=60

# For g4ok and okg4 tests
export LD_LIBRARY_PATH=/usr/local/opticks/externals/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# For tests involving python
export PYTHONPATH=/home/ubuntu/opticks/ana:${PYTHONPATH}