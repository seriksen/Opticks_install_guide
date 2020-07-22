#!/bin/bash

# Valid for opticks 6d76484

# CUDA
export PATH=/usr/local/cuda-10.1/bin:/usr/local/cuda-10.1/NsightCompute-2019.3${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# NVidia OptiX
export LD_LIBRARY_PATH=/home/opc/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Opticks
export LOCAL_BASE=${HOME}
export OPTICKS_HOME=${HOME}/opticks
export PYTHONPATH=${HOME}
export PATH=${OPTICKS_HOME}/bin:${OPTICKS_HOME}/ana:${LOCAL_BASE}/opticks/lib:${PATH}
opticks-(){  [ -r $OPTICKS_HOME/opticks.bash ] && . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }
opticks-     ##

o(){ cd $(opticks-home) ; hg st ; }
op(){ op.sh $* ; }

opticks-cmake-generator(){ echo ${OPTICKS_CMAKE_GENERATOR:-Unix Makefiles} ; }

export OptiX_INSTALL_DIR=/home/opc/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64

export CXXFLAGS="$CXXFLAGS -fPIC"
export CFLAGS="$CFLAGS -fPIC"

export OPTICKS_COMPUTE_CAPABILITY=60

# geometry
# export OPTICKS_KEY=OKX4Test.X4PhysicalVolume.lWorld0x4bc2710_PV.f6cc352e44243f8fa536ab483ad390ce