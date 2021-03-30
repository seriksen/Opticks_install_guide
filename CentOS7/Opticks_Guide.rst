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
Install the externals.
See :code:`Instance_setup/externals_install.sh`

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


Opticks Full
============
This is not the end of the external packages, but the remainder are smaller and are installed as part of :code:`opticks-full`.

Set locations in :code:`opticks_config.sh`. See :doc:`opticks_config.sh`.

Add COMPUTECAPABILITY; The compute capability of the GPU can be found at https://developer.nvidia.com/cuda-gpus.
6.1 = 61, 6.0 = 60 etc...


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

Also (don't know if needed, but keeping from older install), add cmake flags to :code:`opticks_config.sh`

.. code-block:: sh

    export CXXFLAGS="$CXXFLAGS -fPIC"
    export CFLAGS="$CFLAGS -fPIC"


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
Ie in :code:`opticks_config.sh` add :code:`export PYTHONPATH=${HOME};${PYTHONPATH}`.

After this, no tests will fail
