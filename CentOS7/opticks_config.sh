# Opticks Config

# Some useful shortcuts + colour
export PS1='\[\033[02;32m\]\u@\H:\[\033[02;34m\]\w\$\[\033[00m\] '

alias ls='ls --color=auto'
alias vim='vi'
alias la='ls -a --color=auto'
alias ll='la -l -h --color=auto'
alias ..='cd ..; ls'


#scl enable devtoolset-7 bash
export CXXFLAGS="$CXXFLAGS -fPIC"
export CFLAGS="$CFLAGS -fPIC"

opticks-(){  [ -r $HOME/opticks/opticks.bash ] && . $HOME/opticks/opticks.bash && opticks-env $* ; }
opticks-

o(){ opticks- ; cd $(opticks-home) ; git status ; }
oo(){ opticks- ; cd $(opticks-home) ; om- ; om-- ;  }
t(){ typeset -f $* ; }

# PATH envvars control the externals that opticks/CMake or pkg-config will find
unset CMAKE_PREFIX_PATH
unset PKG_CONFIG_PATH


export OPTICKS_EXTERNALS=${HOME}/opticks_externals
export PYTHONPATH=${HOME};${PYTHONPATH}
export OPTICKS_PYTHON=python3
export XERCESC_INSTALL_DIR=${OPTICKS_EXTERNALS}/xerces/xerces-c-3.1.1-install
export OPTICKS_PREFIX=/home/opc/opticks.build
export OPTICKS_CUDA_PREFIX=/usr/local/cuda-11.1
export OPTICKS_OPTIX_PREFIX=${HOME}/NVIDIA/NVIDIA-OptiX-SDK-6.5.0-linux64
export OPTICKS_COMPUTE_CAPABILITY=60

## hookup paths to access externals
opticks-prepend-prefix ${OPTICKS_EXTERNALS}/clhep/clhep_2.4.1.0-install
opticks-prepend-prefix ${OPTICKS_EXTERNALS}/xerces/xerces-c-3.1.1-install
opticks-prepend-prefix ${OPTICKS_EXTERNALS}/g4/geant4.10.06.p02-install
opticks-prepend-prefix ${OPTICKS_EXTERNALS}/boost/boost_1_70_0-install
opticks-check-prefix

echo "CMAKE_PREFIX_PATH ${CMAKE_PREFIX_PATH}"
# Opticks Key for geometry
