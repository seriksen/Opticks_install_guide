# CUDA Path
export PATH=/usr/local/cuda-${CUDA_VERSION}/bin:/usr/local/cuda-${CUDA_VERSION}/NsightCompute-${NsightCompute_version}${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-${CUDA_VERSION}/lib64${LD_LIRARY_PATH:+:${LD_LIBRARY_PATH}}

# Opticks
#export LOCAL_BASE=${HOME}
export LOCAL_BASE=/usr/local
export OPTICKS_HOME=${LOCAL_BASE}/opticks
export PYTHONPATH=${LOCAL_BASE}
export PATH=${OPTICKS_HOME}/bin:${OPTICKS_HOME}/ana:${LOCAL_BASE}/opticks/lib:${PATH}
opticks-(){  [ -r $OPTICKS_HOME/opticks.bash ] && . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }
opticks-     ##

o(){ cd $(opticks-home) ; hg st ; }
op(){ op.sh $* ; }

#In custom_opticks_setup.sh add opticks-cmake-generator
opticks-cmake-generator(){ echo ${OPTICKS_CMAKE_GENERATOR:-Unix Makefiles} ; }
export OPTICKS_INSTALL_PREFIX=${OPTICKS_HOME}
#OptiX_INSTALL_DIR=${INSTALL_BASE}/opticks/externals/OptiX 
OptiX_INSTALL_DIR=${LOCAL_BASE}/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64

# NVidia OptiX Path
export LD_LIBRARY_PATH=$OptiX_INSTALL_DIR/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}


export CXXFLAGS="$CXXFLAGS -fPIC"
export CFLAGS="$CFLAGS -fPIC"

export OPTICKS_COMPUTE_CAPABILITY=60
