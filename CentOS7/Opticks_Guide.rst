**************************
Opticks Installation Guide
**************************

This page contains instructions on how to install Opticks on a system.

This guide was written for installation on Oracle Cloud Instance VMGPU2.1 using;

* Tesla P100 GPU
* NVIDIA Grid (gpu driver)
* NVIDIA CUDA 11.0
* NVIDIA OptiX 6.0

To set up the instance, see the Instance_setup

Additional information;

* I've tried to give the instructions for using just opticks bash functions and for not using them where practical

.. contents:: Contents

###
Pre
###
Setup script
============
Create a setup script :code:`custom_opticks_setup.sh`.
Add cuda path and OptiX path PATH and LD_LIBRARY_PATH

.. code-block:: sh

    # CUDA
    export PATH=/usr/local/cuda-11.0/bin${PATH:+:${PATH}}
    export LD_LIBRARY_PATH=/usr/local/cuda-11.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
    # OptiX
    export LD_LIBRARY_PATH=/home/opc/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

Add execution to :code:`.bashrc` at the top of the file.

sudo yumming
============
Install some things that we will need later

.. code-block:: sh

    sudo yum -y install git \
                        libXcursor-devel \
                        libXinerama-devel \
                        libXrandr-devel \
                        mesa-dri-drivers \
                        mesa-libGLES \
                        mesa-libGLw \
                        mesa-libGLw-devel \
                        freeglut-devel \
                        freeglut \
                        expat-devel \
                        doxygen

.

#######
Opticks
#######
Get opticks

.. code-block:: sh

    git clone git@bitbucket.org:SamEriksen/opticks.git

Add the following to :code:`custom_opticks_setup.sh` to make interacting with Opticks easier

.. code-block:: sh

    # Opticks
    export PYTHONPATH=${HOME}
    export OPTICKS_HOME=${HOME}/opticks
    opticks-(){ [ -r $OPTICKS_HOME/opticks.bash ] && . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }
    opticks-
    export PATH=${OPTICKS_HOME}/bin:${OPTICKS_HOME}/ana:${LOCAL_BASE}/opticks/lib${PATH:+:${PATH}}
    export OPTICKS_PREFIX=/home/opc/opticks # opticks will put things in opticks_externals


Now go through installing the needed bits. So see what opticks actually needs, run :code:`opticks-info`
After installing things, rerun opticks-info to check opticks variables and requirements are met.

cmake
=====
What's required? cmake 3.14+.

Opticks bash functions
----------------------
Install cmake by;

.. code-block:: sh

    ocmake-
    ocmake-info
    ocmake--

Direct
------

.. code-block:: sh

    cmake_ver=3.14.1
    dir=/home/opc/opticks_externals/cmake
    mkdir -p ${dir}
    cd ${dir}
    url=https://github.com/Kitware/CMake/releases/download/v${cmake_ver}/cmake-${cmake_ver}.tar.gz
    curl -L -O ${url}
    tar zxvf cmake-${cmake_ver}.tar.gz
    cd cmake-${cmake_ver}
    ./bootstrap
    gmake
    sudo make install

boost
=====
What's required? Boost v 1.59+

Opticks bash
------------
.. code-block:: sh

    boost-
    boost--

Direct
------
.. code-block:: sh

    boost_v0=1.70.0
    boost_ver=1_17_0
    dir=/home/opc/boost
    mkdir -p ${dir}
    cd ${dir}
    url=http://downloads.sourceforge.net/project/boost/boost/${boost_v0}/boost_${boost_ver}.tar.gz
    curl -L -O ${url}
    tar zxvf boost_${boost_ver}.tar.gz
    cd boost_${boost_ver}
    ./bootstrap.sh
    ./b2 install

(or for boost 1.53, :code:`sudo yum install boost`)

Opticks Externals
=================
List of externals (excluding the above + NVIDIA)

bcm
glm
glfw
glew
gleq
imgui
assimp
openmesh
plog
opticksaux
oimplicitmesher
odcs
oyoctogl
ocsgbsp

opticks-optionals-install installs...

* boost
* clhep
* xercesc
* geant4








