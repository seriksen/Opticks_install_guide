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
Defaul is likely to be 4.8.5 (CentOS7)

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

The fails are due to python not finding the :code:`opticks` module;

interpolationTest
*****************

.. code-block:: sh

    Start 21: OptiXRapTest.interpolationTest
    21/28 Test #21: OptiXRapTest.interpolationTest ..............................***Failed   11.01 sec
    2020-10-04 19:20:29.127 INFO  [11343] [BOpticksKey::SetKey@75]  spec OKX4Test.X4PhysicalVolume.World0xc15cfc00x40f7000_PV.5aa828335373870398bf4f738781da6c
    2020-10-04 19:20:29.129 INFO  [11343] [Opticks::init@405] COMPUTE_MODE forced_compute  hostname opticksbuild
    2020-10-04 19:20:29.129 INFO  [11343] [Opticks::init@414]  non-legacy mode : ie mandatory keyed access to geometry, opticksaux
    2020-10-04 19:20:29.135 INFO  [11343] [BOpticksResource::setupViaKey@832]
                 BOpticksKey  :
          spec (OPTICKS_KEY)  : OKX4Test.X4PhysicalVolume.World0xc15cfc00x40f7000_PV.5aa828335373870398bf4f738781da6c
                     exename  : OKX4Test
             current_exename  : interpolationTest
                       class  : X4PhysicalVolume
                     volname  : World0xc15cfc00x40f7000_PV
                      digest  : 5aa828335373870398bf4f738781da6c
                      idname  : OKX4Test_World0xc15cfc00x40f7000_PV_g4live
                      idfile  : g4ok.gltf
                      idgdml  : g4ok.gdml
                      layout  : 1

    2020-10-04 19:20:29.136 INFO  [11343] [Opticks::loadOriginCacheMeta@1853]  cachemetapath /home/opc/.opticks/geocache/OKX4Test_World0xc15cfc00x40f7000_PV_g4live/g4ok_gltf/5aa828335373870398bf4f738781da6c/1/cachemeta.json
    2020-10-04 19:20:29.136 INFO  [11343] [NMeta::dump@199] Opticks::loadOriginCacheMeta
    {
        "argline": "/home/opc/opticks.build/lib/OKX4Test --okx4test --g4codegen --deletegeocache --gdmlpath /home/opc/opticks.build/opticksaux/export/DayaBay_VGDX_20140414-1300/g4_00_CGeometry_export_v0.gdml --x4polyskip 211,232 --geocenter --noviz --runfolder geocache-dx0 --runcomment export-dyb-gdml-from-g4-10-4-2-to-support-geocache-creation.rst ",
        "location": "Opticks::updateCacheMeta",
        "runcomment": "export-dyb-gdml-from-g4-10-4-2-to-support-geocache-creation.rst",
        "rundate": "20201004_191350",
        "runfolder": "geocache-dx0",
        "runlabel": "R0_cvd_",
        "runstamp": 1601838830
    }
    2020-10-04 19:20:29.136 INFO  [11343] [Opticks::loadOriginCacheMeta@1857]  gdmlpath /home/opc/opticks.build/opticksaux/export/DayaBay_VGDX_20140414-1300/g4_00_CGeometry_export_v0.gdml
    2020-10-04 19:20:29.136 ERROR [11343] [OpticksHub::configure@331] FORCED COMPUTE MODE : as remote session detected
    2020-10-04 19:20:29.136 INFO  [11343] [OpticksHub::loadGeometry@541] [ /home/opc/.opticks/geocache/OKX4Test_World0xc15cfc00x40f7000_PV_g4live/g4ok_gltf/5aa828335373870398bf4f738781da6c/1
    2020-10-04 19:20:29.185 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/0/placement_iidentity.npy
    2020-10-04 19:20:29.229 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/1/placement_iidentity.npy
    2020-10-04 19:20:29.230 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/2/placement_iidentity.npy
    2020-10-04 19:20:29.230 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/3/placement_iidentity.npy
    2020-10-04 19:20:29.231 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/4/placement_iidentity.npy
    2020-10-04 19:20:29.232 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/5/placement_iidentity.npy
    2020-10-04 19:20:29.266 INFO  [11343] [GMesh::loadNPYBuffer@1961]  loading iidentity GMergedMesh/6/placement_iidentity.npy
    2020-10-04 19:20:29.318 INFO  [11343] [GNodeLib::GNodeLib@90] loaded
    2020-10-04 19:20:34.511 INFO  [11343] [NMeta::dump@199] GGeo::loadCacheMeta.lv2sd
    2020-10-04 19:20:34.511 INFO  [11343] [NMeta::dump@199] GGeo::loadCacheMeta.lv2mt
    2020-10-04 19:20:34.526 ERROR [11343] [Opticks::setupTimeDomain@2549]  animtimerange -1.0000,-1.0000,0.0000,0.0000
    2020-10-04 19:20:34.526 INFO  [11343] [Opticks::setupTimeDomain@2560]  cfg.getTimeMaxThumb [--timemaxthumb] 6 cfg.getAnimTimeMax [--animtimemax] -1 cfg.getAnimTimeMax [--animtimemax] -1 speed_of_light (mm/ns) 300 extent (mm) 2.4e+06 rule_of_thumb_timemax (ns) 48000 u_timemax 48000 u_animtimemax 48000
    2020-10-04 19:20:34.526 FATAL [11343] [Opticks::setProfileDir@546]  dir /tmp/opc/opticks/interpolationTest/evt/g4live/torch
    2020-10-04 19:20:34.530 INFO  [11343] [OpticksHub::loadGeometry@585] ]
    2020-10-04 19:20:35.415 FATAL [11343] [Opticks::makeSimpleTorchStep@3354]  enable : --torch (the default)  configure : --torchconfig [NULL] dump details : --torchdbg
    2020-10-04 19:20:35.415 ERROR [11343] [OpticksGen::makeTorchstep@407]  as torchstep isDefault replacing placeholder frame  frameIdx : 0 detectorDefaultFrame : 0
    2020-10-04 19:20:35.415 INFO  [11343] [OpticksGen::targetGenstep@336] setting frame 0 Id
    2020-10-04 19:20:35.415 ERROR [11343] [OpticksGen::makeTorchstep@431]  generateoverride 0 num_photons0 10000 num_photons 10000
    2020-10-04 19:20:35.416 ERROR [11343] [OContext::SetupOptiXCachePathEnvvar@286] envvar OPTIX_CACHE_PATH not defined setting it internally to /var/tmp/opc/OptiXCache
    2020-10-04 19:20:35.712 INFO  [11343] [OContext::InitRTX@323]  --rtx 0 setting  OFF
    2020-10-04 19:20:35.814 INFO  [11343] [OContext::CheckDevices@207]
    Device 0           Tesla P100-SXM2-16GB ordinal 0 Compute Support: 6 0 Total Memory: 17071734784

    2020-10-04 19:20:35.831 INFO  [11343] [CDevice::Dump@230] Visible devices[0:Tesla_P100-SXM2-16GB]
    2020-10-04 19:20:35.831 INFO  [11343] [CDevice::Dump@234] CDevice index 0 ordinal 0 name Tesla P100-SXM2-16GB major 6 minor 0 compute_capability 60 multiProcessorCount 56 totalGlobalMem 17071734784
    2020-10-04 19:20:35.831 INFO  [11343] [CDevice::Dump@230] All devices[0:Tesla_P100-SXM2-16GB]
    2020-10-04 19:20:35.831 INFO  [11343] [CDevice::Dump@234] CDevice index 0 ordinal 0 name Tesla P100-SXM2-16GB major 6 minor 0 compute_capability 60 multiProcessorCount 56 totalGlobalMem 17071734784
    2020-10-04 19:20:35.831 INFO  [11343] [OScene::init@119] [
    2020-10-04 19:20:35.934 INFO  [11343] [OGeo::init@237] OGeo  top Sbvh ggg Sbvh assembly Sbvh instance Sbvh
    2020-10-04 19:20:35.934 INFO  [11343] [GGeoLib::dump@369] OGeo::convert GGeoLib TRIANGULATED  numMergedMesh 7 ptr 0x2164990
    mm index   0 geocode   T                  numVolumes      12230 numFaces      480972 numITransforms           1 numITransforms*numVolumes       12230 GParts Y GPts Y
    mm index   1 geocode   T                  numVolumes          1 numFaces          12 numITransforms        1792 numITransforms*numVolumes        1792 GParts Y GPts Y
    mm index   2 geocode   T                  numVolumes          1 numFaces          12 numITransforms         864 numITransforms*numVolumes         864 GParts Y GPts Y
    mm index   3 geocode   T                  numVolumes          1 numFaces          12 numITransforms         864 numITransforms*numVolumes         864 GParts Y GPts Y
    mm index   4 geocode   T                  numVolumes          1 numFaces          12 numITransforms         864 numITransforms*numVolumes         864 GParts Y GPts Y
    mm index   5 geocode   T                  numVolumes          5 numFaces        2976 numITransforms         672 numITransforms*numVolumes        3360 GParts Y GPts Y
    mm index   6 geocode   T                  numVolumes       4486 numFaces      480972 numITransforms           1 numITransforms*numVolumes        4486 GParts Y GPts Y
     num_total_volumes 12230 num_instanced_volumes 12230 num_global_volumes 0 num_total_faces 964968 num_total_faces_woi 3014424 (woi:without instancing)
       0 pts Y  GPts.NumPt  4486 lvIdx ( 248 247 21 0 7 6 3 2 3 2 ... 237 238 239 240 241 242 243 244 245)
       1 pts Y  GPts.NumPt     1 lvIdx ( 1)
       2 pts Y  GPts.NumPt     1 lvIdx ( 197)
       3 pts Y  GPts.NumPt     1 lvIdx ( 195)
       4 pts Y  GPts.NumPt     1 lvIdx ( 198)
       5 pts Y  GPts.NumPt     5 lvIdx ( 47 46 43 44 45)
       6 pts Y  GPts.NumPt  4486 lvIdx ( 248 247 21 0 7 6 3 2 3 2 ... 237 238 239 240 241 242 243 244 245)
    2020-10-04 19:20:35.935 INFO  [11343] [OGeo::convert@263] [ nmm 7
    2020-10-04 19:20:35.936 INFO  [11343] [GMesh::makeFaceRepeatedIdentityBuffer@2411]  mmidx 0 numITransforms 1 numVolumes 12230 numFaces (sum of faces in numVolumes)480972 numFacesCheck 480972
    2020-10-04 19:20:35.990 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2277]  mmidx 1 numITransforms 1792
    2020-10-04 19:20:35.990 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2337]  nftot 12 numFaces 12
    2020-10-04 19:20:36.108 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2277]  mmidx 2 numITransforms 864
    2020-10-04 19:20:36.108 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2337]  nftot 12 numFaces 12
    2020-10-04 19:20:36.142 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2277]  mmidx 3 numITransforms 864
    2020-10-04 19:20:36.142 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2337]  nftot 12 numFaces 12
    2020-10-04 19:20:36.177 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2277]  mmidx 4 numITransforms 864
    2020-10-04 19:20:36.178 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2337]  nftot 12 numFaces 12
    2020-10-04 19:20:36.213 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2277]  mmidx 5 numITransforms 672
    2020-10-04 19:20:36.213 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2337]  nftot 2976 numFaces 2976
    2020-10-04 19:20:36.303 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2277]  mmidx 6 numITransforms 1
    2020-10-04 19:20:36.303 INFO  [11343] [GMesh::checks_faceRepeatedInstancedIdentity@2337]  nftot 480972 numFaces 480972
    2020-10-04 19:20:36.326 INFO  [11343] [OGeo::convert@276] ] nmm 7
    2020-10-04 19:20:36.332 INFO  [11343] [OScene::init@182] ]
    2020-10-04 19:20:36.333 INFO  [11343] [main@189]  ok
    2020-10-04 19:20:36.336 INFO  [11343] [BFile::preparePath@812] created directory /tmp/opc/opticks/optixrap/interpolationTest/GItemList
    2020-10-04 19:20:36.336 INFO  [11343] [interpolationTest::init@115]  name interpolationTest_interpol.npy base $TMP/optixrap/interpolationTest script interpolationTest_interpol.py nb   127 nx   761 ny  1016 progname              interpolationTest
    2020-10-04 19:20:36.336 INFO  [11343] [OLaunchTest::init@69] OLaunchTest entry   0 width       1 height       1 ptx                               interpolationTest.cu prog                                  interpolationTest
    2020-10-04 19:20:36.336 INFO  [11343] [OLaunchTest::launch@80] OLaunchTest entry   0 width     761 height     127 ptx                               interpolationTest.cu prog                                  interpolationTest
    2020-10-04 19:20:39.455 INFO  [11343] [interpolationTest::launch@158] OLaunchTest entry   0 width     761 height     127 ptx                               interpolationTest.cu prog                                  interpolationTest
    2020-10-04 19:20:39.482 INFO  [11343] [interpolationTest::launch@165]  save  base $TMP/optixrap/interpolationTest name interpolationTest_interpol.npy
    2020-10-04 19:20:39.521 INFO  [11343] [SSys::RunPythonScript@501]  script interpolationTest_interpol.py script_path /home/opc/opticks.build/bin/interpolationTest_interpol.py python_executable /usr/bin/python3
    Traceback (most recent call last):
      File "/home/opc/opticks.build/bin/interpolationTest_interpol.py", line 23, in <module>
        from opticks.ana.proplib import PropLib
    ModuleNotFoundError: No module named 'opticks'
    2020-10-04 19:20:39.789 INFO  [11343] [SSys::run@100] /usr/bin/python3 /home/opc/opticks.build/bin/interpolationTest_interpol.py  rc_raw : 256 rc : 1
    2020-10-04 19:20:39.789 ERROR [11343] [SSys::run@107] FAILED with  cmd /usr/bin/python3 /home/opc/opticks.build/bin/interpolationTest_interpol.py  RC 1
    2020-10-04 19:20:39.789 INFO  [11343] [SSys::RunPythonScript@508]  RC 1


tboolean
********

.. code-block:: sh

    Start 2: IntegrationTests.tboolean.box
    2/2 Test #2: IntegrationTests.tboolean.box ......***Failed    0.15 sec
    ====== /home/opc/opticks.build/bin/tboolean.sh --generateoverride 10000 ====== PWD /home/opc/opticks.build/build/integration/tests =================
    tboolean-lv --generateoverride 10000
    === tboolean-lv : tboolean-box cmdline --generateoverride 10000
    Traceback (most recent call last):
      File "<stdin>", line 3, in <module>
    ModuleNotFoundError: No module named 'opticks'
    === tboolean-box : testconfig

    tboolean-info
    ==================


    BASH_VERSION         : 4.2.46(2)-release
    TESTNAME             : tboolean-box
    TESTCONFIG           :
    TORCHCONFIG          :

    tboolean-testname    : tboolean-box
    tboolean-testconfig  :
    tboolean-torchconfig : type=disc_photons=100000_mode=fixpol_polarization=1,1,0_frame=-1_transform=1.000,0.000,0.000,0.000,0.000,1.000,0.000,0.000,0.000,0.000,1.000,0.000,0.000,0.000,0.000,1.000_source=0,0,599_target=0,0,0_time=0.0_radius=300_distance=200_zenithazimuth=0,1,0,1_material=Vacuum_wavelength=500


    === tboolean-- : no testconfig : try tboolean-box-
    === tboolean-lv : tboolean-box RC 255
    ====== /home/opc/opticks.build/bin/tboolean.sh --generateoverride 10000 ====== PWD /home/opc/opticks.build/build/integration/tests ============ RC 255 =======












