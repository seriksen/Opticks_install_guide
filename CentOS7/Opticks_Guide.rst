**************************
Opticks Installation Guide
**************************

This page contains instructions on how to install Opticks on a system.

This guide was written for installation on Oracle Cloud Instance VMGPU2.1 using;

* Tesla P100 GPU
* NVIDIA Grid (gpu driver)
* NVIDIA CUDA 11.1.0
* NVIDIA OptiX 6.5.0

To set up the instance, see the Instance_setup

.. contents:: Contents

###
Pre
###
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
                        libGL-devel \
                        curl-devel \ # for cmake
                        openssl-devel # for sysrap

Could also do (to avoid later...)

.. code-block:: sh

    sudo yum install xerces-c xerces-c-devel # But I didn't in this install

#######
Opticks
#######
Opticks as a package, is actually a bunch of smaller CMake projects.
These are linked using CMake 'find_package' and boost cmake modules (bcm)

Get Opticks
===========

.. code-block:: sh

    git clone git@bitbucket.org:SamEriksen/opticks.git


Config Script
=============
In order to use opticks, several enviromental variables need to be set.
An example script is at :code:`opticks/example.opticks_config` and may be a good starting point.
Copy the script and source in bashrc.
Add execution to :code:`.bashrc` at the top of the file.

.. code-block:: sh

    cp opticks/example.opticks_config ~/opticks_config.sh


Opticks Externals
=================
In this guide, as much as possible will be put into a directory :code:`opticks_externals`.

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
    ./bootstrap --system-curl #system-curl needed for G4 SSL download
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
    ./bootstrap.sh --prefix=${dir}/$boost_name
    ./b2 --prefix=${dir} --build-dir=${dir}/${boost_name}.build --with-system --with-thread --with-program_options --with-log --with-filesystem --with-regex install


chlep
-----
.. code-block:: sh

    chlep_version=2.4.1.0
    url=http://proj-clhep.web.cern.ch/proj-clhep/DISTRIBUTION/tarFiles/clhep-${clhep_version}.tgz
    dir=${OPTICKS_EXTERNALS}/chlep
    mkdir -p $dir
    cd $dir
    curl -L -O $url
    tar zxf $(basename $url)
    mkdir clhep_${clhep_version}.build
    cd clhep_${clhep_version}.build
    cmake ../${clhep_version}/CLHEP
    make
    sudo make install

xcerses
-------
.. code-block:: sh

    xerces_version=3.1.1
    url=http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${xerces_version}.tar.gz
    dir=${OPTICKS_EXTERNALS}/xerces
    mkdir -p $dir
    cd $dir
    curl -L -O $url
    tar zxf $(basename $url)
    cd xerces-c-${xerces_version}
    ./configure --prefix=${dir}/build
    mkdir ../build
    sudo make install

Geant4
------
Note, in order to use G4.10.06 needs gcc 4.9.3+.
Defaul is likely to be 4.8.5 (CentOS7).
Earlier versions are fine with 4.8.5.

.. code-block:: sh

    g4_version=geant4.10.06.p02
    dir=${OPTICKS_EXTERNALS}/g4
    mkdir -p ${dir}
    cd ${dir}
    url=http://cern.ch/geant4-data/releases/${g4_version}.tar.gz
    curl -L -O $url
    tar zxf ${g4_version}.tar.gz
    mkdir ${g4_version}.build
    cd ${g4_version}.build
    cmake -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE=Debug \
          -DGEANT4_INSTALL_DATA=ON \
          -DGEANT4_USE_GDML=ON \
          -DGEANT4_USE_SYSTEM_CLHEP=ON \
          -DGEANT4_INSTALL_DATA_TIMEOUT=3000 \
          -DXERCESC_ROOT_DIR=/home/opc/opticks_externals/xerces/build \
          -DCMAKE_INSTALL_PREFIX=${dir}/${g4_version}.build \
          ${dir}/${g4_version}
    make
    make install

For gcc...

.. code-block:: sh

    sudo yum install centos-release-scl
    sudo yum install devtoolset-7
    scl enable devtoolset-7 bash # if added to opticks_config.sh will need Ctlr + C twice

Opticks Full
============
This is not the end of the external packages, but the remainder are smaller and are installed as part of :code:`opticks-full`.

Set locations in :code:`opticks_config.sh`.

Then edits to cmake.

FindG4.cmake
------------
Edit line 46 to be; :code:`list(GET _dirs 30 _firstdir)`

Edit line 100 to be; :code:`PATHS "${G4_DIR}/lib64")`


FindOpticksXercesC.cmake
------------------------
Edit line 98 to be; :code:`/home/opc/opticks_externals/xerces/build/include`

Edit line 114 to be; :code:`/home/opc/opticks_externals/xerces/build/lib`


Testing Opticks
===============
At this stage if the unit tests are run 87/435 will fail.
This is primarily due to the lack of geocache.

Getting geocache
----------------
Easiest to do the tests with the JUNO geometry.
Get it by; :code:`git clone git@bitbucket.org:simoncblyth/opticksdata.git`

.. code-block:: sh

    geocache-
    geocache-create

This will output something at the end like

.. code-block:: sh

    2020-10-04 19:14:28.028 FATAL [9633] [Opticks::reportGeoCacheCoordinates@1003] THE LIVE keyspec DOES NOT MATCH THAT OF THE CURRENT ENVVAR
    2020-10-04 19:14:28.028 INFO  [9633] [Opticks::reportGeoCacheCoordinates@1004]  (envvar) OPTICKS_KEY=NONE
    2020-10-04 19:14:28.028 INFO  [9633] [Opticks::reportGeoCacheCoordinates@1005]  (live)   OPTICKS_KEY=OKX4Test.X4PhysicalVolume.World0xc15cfc00x40f7000_PV.5aa828335373870398bf4f738781da6c

Add the :code:`OPTICKS_KEY` to the :code:`opticks_config.sh` script.

.. code-block:: sh

    export OPTICKS_KEY=OKX4Test.X4PhysicalVolume.World0xc15cfc00x40f7000_PV.5aa828335373870398bf4f738781da6c
    export OPTICKS_KEYDIR=$(opticks-keydir) # Haven't checked if this is actually needed

In this guide, the geocache will be created in :code:`${HOME}/.opticks/geocache`.

Additional
----------
Given that python2 is no longer supported, it is best to use python3.
It's best to use conda (not what's being done here)

.. code-block:: sh

    sudo yum install python3
    sudo pip3 install numpy ipython

And then set Opticks to use python3 in :code:`opticks_config.sh`. Add :code:`export OPTICKS_PYTHON=python3`.
For additional information on version requirements, see older guides.


Running tests
-------------
Tests can now be run by :code:`opticks-t`.
This will run 435 tests.

As of right now, 2 tests will fail and 4 will be slow;

.. code-block:: sh

  SLOW: tests taking longer that 15 seconds
  44 /57  Test #44 : GGeoTest.GMakerTest                           Passed                         16.90
  15 /28  Test #15 : OptiXRapTest.rayleighTest                     Passed                         20.39
  7  /34  Test #7  : CFG4Test.CG4Test                              Passed                         21.04
  1  /1   Test #1  : OKG4Test.OKG4Test                             Passed                         27.30

  FAILS:  2   / 435   :  Sun Oct  4 19:23:54 2020
  21 /28  Test #21 : OptiXRapTest.interpolationTest                ***Failed                      11.01
  2  /2   Test #2  : IntegrationTests.tboolean.box                 ***Failed                      0.15

The fails are due to python not finding the :code:`opticks` module.

To correct this, add ${HOME} to PYTHONPATH.
Ie in :code:`opticks_config.sh` add :code:`export PYTHONPATH=${HOME};${PYTHONPATH}.

After this, no tests will fail
