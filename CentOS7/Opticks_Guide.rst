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
Although Opticks does have bash functions which install all of the functions which has some benifits, it is best to try
and keep all of the externals separate.
In this guide, I've put all of the externals for opticks in a directory called :code:`opticks_externals`.
This is in preparation of minimising what is actually in Opticks.

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
                        doxygen \
                        libXmu-devel \
                        libXi-devel \
                        libGL-devel

#######
Opticks
#######
Opticks as a package, is actually a bunch of smaller CMake projects.
These are linked using CMake 'find_package' and boost cmake modules (bcm)

Get Opticks
===========

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
    export OPTICKS_EXTERNALS=/home/opc/opticks_externals


Now go through installing the needed bits. So see what opticks actually needs, run :code:`opticks-info`
After installing things, rerun opticks-info to check opticks variables and requirements are met.

Opticks Externals
=================
Opticks has many external dependencies;

* cmake (3.14+)
* boost (1.59+)
* bcm
* glm
* glfw
* glew
* gleq
* imgui
* assimp
* openmesh
* plog
* opticksaux
* oimplicitmesher
* odcs
* oyoctogl
* ocsgbsp
* xercesc
* geant4

cmake
-----
.. code-block:: sh

    cmake_ver=3.14.1
    dir=${OPTICKS_EXTERNALS}/cmake
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
-----
.. code-block:: sh

    boost_ver=1.70.0
    boost_name=boost_${boost_ver//./_}
    dir=${OPTICKS_EXTERNALS}/boost
    mkdir -p ${dir}
    cd ${dir}
    url=http://downloads.sourceforge.net/project/boost/boost/${boost_ver}/${boost_name}.tar.gz
    curl -L -O ${url}
    tar zxf ${boost_name}.tar.gz
    cd ${boost_name}
    ./bootstrap.sh --prefix=${dir}
    ./b2 --prefix=${dir} --build-dir=${dir}/${boost_name}.build --with-system --with-thread --with-program_options --with-log --with-filesystem --with-regex install

bcm
---
.. code-block:: sh

    dir=${OPTICKS_EXTERNALS}/bcm
    mkdir -p $dir
    cd $dir
    url=http://github.com/simoncblyth/bcm.git
    git clone $url
    mkdir ${dir}/bcm.build
    cd ${dir}/bcm.build
    cmake ../bcm -DCMAKE_INSTALL_PREFIX=${OPTICKS_EXTERNALS}
    cmake --build . --target install

glm
---
.. code-block:: sh

    glm_ver=0.9.9.5
    glm_name=glm-${glm_ver}
    dir=${OPTICKS_EXTERNALS}/glm
    mkdir -p $dir
    cd $dir
    url=https://github.com/g-truc/glm/releases/download/${glm_ver}/${glm_name}.zip
    curl -L -O $url
    unzip ${glm_name}.zip -d ${glm_name}

Then point to Opticks (these steps should change).
Do :code:`mkdir -p /home/opc/opticks/externals/lib/pkgconfig/`
Add to :code:`/home/opc/opticks/externals/lib/pkgconfig/GLM.pc` and fill with.
.. code-block:: sh

    prefix=/home/opc/opticks_externals
    includedir=${prefix}/glm/glm

    Name: GLM
    Description: Mathematics
    Version: 0.1.0

    Cflags:  -I${includedir}
    Libs: -lstdc++
    Requires:

glfw
----
.. code-black:: sh

    glfw_ver=3.3.2
    dir=${OPTICKS_EXTERNALS}/glfw
    mkdir -p $dir
    cd $dir
    url=https://github.com/glfw/glfw/releases/download/${glfw_ver}/glfw-${glfw_ver}.zip
    curl -L -O $url
    unzip glfw-${glfw_ver}.zip
    mkdir ${dir}/glfw-${glfw_ver}.build
    cd ${dir}/glfw-${glfw_ver}.build
    cmake -G "Unix Makefiles" \
          -DBUILD_SHARED_LIBS=ON \
          -DDOpenGL_GL_PREFERENCE=LEGACY \
          -DCMAKE_INSTALL_PREFIX=${dir} \
          ../glfw-${glfw_ver}
    cmake --build . --config Debug --target install
    cp ${OPTICKS_EXTERNALS}/glfw/lib64/pkgconfig/glfw3.pc /home/opc/opticks/externals/lib/pkgconfig/OpticksGLFW.pc

glew
----
OpenGL extension.
The basic instructions are on the projects github: https://github.com/nigels-com/glew
Requires :code:`sudo yum install libXmu-devel libXi-devel libGL-devel`

.. code-block:: sh

    glew_ver=2.1.0
    dir=${OPTICKS_EXTERNALS}/glew
    mkdir -p $dir
    cd $dir
    url=http://downloads.sourceforge.net/project/glew/glew/${glew_ver}/glew-${glew_ver}.zip
    curl -L -O $url
    unzip glew-${glew_ver}.zip
    cd glew-${glew_ver}
    builddir=${dir}/glew-${glew_ver}.build
    make install GLEW_PREFIX=${builddir} GLEW_DEST=${builddir} LIBDIR=${builddir}/lib
    cp ${builddir}/lib/pkgconfig/glew.pc /home/opc/opticks/externals/lib/pkgconfig/OpticksGLEW.pc

gleq
----
Event Queue for GLFW.
It is just a header file.
This is already in opticks/oglrap/gleq.h ... so is it needed as an external here? Should refer to this version if wanted

.. code-block:: sh

    dir=${OPTICKS_EXTERNALS}/gleq
    mkdir -p $dir
    cd $dir
    git clone https://github.com/glfw/gleq.git

imgui
-----
Graphical UI library for C++.
Has a different CMakeList. Why?

.. code-block:: sh

    dir=${OPTICKS_EXTERNALS}/imgui
    mkdir -p $dir
    cd $dir
    url=http://github.com/simoncblyth/imgui.git
    git clone $url
    mkdir imgui.build
    cd imgui.build
    cmake -G "Unix Makefiles" \
          -DOPTICKS_PREFIX=/home/opc/opticks \
          -DCMAKE_INSTALL_PREFIX=${dir} \
          -DCMAKE_MODULE_PATH=${OPTICKS_EXTERNALS}/cmake/Modules \
          -DCMAKE_PREFIX_PATH=/home/opc/opticks/externals \
          -DCMAKE_BUILD_TYPE=Debug \
          ${dir}/imgui


TODO: Change Opticks cmake Finds to use different variable so don't have to be saved in $Opticks_prefix / externals



Opticks Externals
=================
List of externals (excluding the above + NVIDIA)

bcm
glm
glfw
glew
gleq -
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








