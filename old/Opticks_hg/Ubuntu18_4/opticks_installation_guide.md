# File containing the info for setting up Opticks on VM.GPU2.1 instance
These instructions are only for Ubuntu currently.

This guide uses
```code
Oracle VM.GPU2.1 with Tesla P100
Ubuntu 18.04
CUDA 10.1
NVidia OptiX 6.0.0
Opticks 6506513 https://bitbucket.org/simoncblyth/opticks/commits/6506513367e68c8da77a3f04c74e32af72cf601e
```

## Setup X11
X11 is required for NVidia OptiX tests.
```code
ubuntu@bristollz:~$ sudo apt install x11-apps

# Now log in using -X for X11 forwarding
ak18773@samsdell:~$ ssh -A -X ubuntu@132.145.219.8

# Verify
ubuntu@bristollz:~$ xclock
```

## Install Nvidia driver
The installation and verification of the driver is described here. 
These instructions are taken from https://www.mvps.net/docs/install-nvidia-drivers-ubuntu-18-04-lts-bionic-beaver-linux/.
The guide recommends using screen however, the installation only takes 10 minutes so is not necessary.
```code
# Check that there is a GPU
ubuntu@bristollz:~$ lspci | grep NVIDIA
00:04.0 3D controller: NVIDIA Corporation GP100GL [Tesla P100 SXM2 16GB] (rev a1)

# clean the system of other Nvidia drivers
ubuntu@bristollz:~$ sudo apt-get purge nvidia*

# Add graphics card PPA
ubuntu@bristollz:~$ sudo add-apt-repository ppa:graphics-drivers

# Update system
ubuntu@bristollz:~$ sudo apt-get update

# Install GPU driver, takes <5 minutes
ubuntu@bristollz:~$ sudo apt-get install nvidia-driver-430

# Need to reboot system
ubuntu@bristollz:~$ sudo reboot

# Verify the driver is there
ubuntu@bristollz:~$ lsmod | grep nvidia
nvidia_uvm            815104  0
nvidia_drm             45056  0
nvidia_modeset       1110016  1 nvidia_drm
nvidia              18792448  2 nvidia_uvm,nvidia_modeset
drm_kms_helper        167936  1 nvidia_drm
drm                   401408  3 drm_kms_helper,nvidia_drm
ipmi_msghandler        53248  2 ipmi_devintf,nvidia

ubuntu@bristollz:~$ nvidia-smi
Wed Jun 12 11:56:27 2019       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 430.26       Driver Version: 430.26       CUDA Version: 10.2     |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  Tesla P100-SXM2...  Off  | 00000000:00:04.0 Off |                    0 |
| N/A   34C    P0    25W / 300W |      0MiB / 16280MiB |      0%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|  No running processes found                                                 |
+-----------------------------------------------------------------------------+
```

## Install CUDA
Instruction are taken from https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#ubuntu-installation and the cuda download instructions from https://developer.nvidia.com/cuda-downloads.
The post installation actions can found at https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#post-installation-actions.

```code
# Download deb file
ubuntu@bristollz:~$ wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.1.168-1_amd64.deb

# Install CUDA
ubuntu@bristollz:~$ sudo dpkg -i cuda-repo-ubuntu1804_10.1.168-1_amd64.deb
ubuntu@bristollz:~$ sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
ubuntu@bristollz:~$ sudo apt-get update
ubuntu@bristollz:~$ sudo apt-get install cuda

# Post installation actions (add exports to .bashrc)
ubuntu@bristollz:~$ export PATH=/usr/local/cuda-10.1/bin:/usr/local/cuda-10.1/NsightCompute-2019.1${PATH:+:${PATH}}
ubuntu@bristollz:~$ export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
ubuntu@bristollz:~$ sudo reboot

# CUDA extras (optional, but some are needed later. It is likely that they are already installed)
ubuntu@bristollz:~$ sudo apt-get install g++ freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev

# Verify CUDA
# THERE may be an issue with setting up the enviroment (call the exports from post install actions to fix)
ubuntu@bristollz:~$ mkdir cuda-samples
ubuntu@bristollz:~$ cuda-install-samples-10.1.sh cuda-samples/
ubuntu@bristollz:~$ nvcc --version
nvcc: NVIDIA (R) Cuda compiler driver
Copyright (c) 2005-2019 NVIDIA Corporation
Built on Wed_Apr_24_19:10:27_PDT_2019
Cuda compilation tools, release 10.1, V10.1.168

ubuntu@bristollz:~$ cd cuda-samples/NVIDIA_CUDA-10.1_Samples/0_Simple/simpleAssert
ubuntu@bristollz:~/cuda-samples/NVIDIA_CUDA-10.1_Samples/0_Simple/simpleAssert$ make
ubuntu@bristollz:~/cuda-samples/NVIDIA_CUDA-10.1_Samples/0_Simple/simpleAssert$ ./simpleAssert 
simpleAssert starting...
OS_System_Type.release = 4.15.0-1013-oracle
OS Info: <#15-Ubuntu SMP Wed May 8 15:10:28 UTC 2019>

GPU Device 0: "Tesla P100-SXM2-16GB" with compute capability 6.0

Launch kernel to generate assertion failures

-- Begin assert output

simpleAssert.cu:47: void testKernel(int): block: [1,0,0], thread: [28,0,0] Assertion `gtid < N` failed.
simpleAssert.cu:47: void testKernel(int): block: [1,0,0], thread: [29,0,0] Assertion `gtid < N` failed.
simpleAssert.cu:47: void testKernel(int): block: [1,0,0], thread: [30,0,0] Assertion `gtid < N` failed.
simpleAssert.cu:47: void testKernel(int): block: [1,0,0], thread: [31,0,0] Assertion `gtid < N` failed.

-- End assert output

Device assert failed as expected, CUDA error message is: device-side assert triggered

simpleAssert completed, returned OK
```

## Install Nvidia OptiX
To get OptiX requires an account with the NVIDIA developer program https://developer.nvidia.com/optix.
An account is free.
Once you have an account, download the bash script from the address above.
You must then upload this script to Oracle.
```code
# Prepare instance
ubuntu@bristollz:~$ mkdir OptiX

# Upload to OCI instance
# Note, this is a few hundred MB so takes a few minutes
ak18773@samsdell:~/Downloads$ scp NVIDIA-OptiX-SDK-6.0.0-linux64-25650775.sh ubuntu@132.145.219.8:/home/ubuntu/OptiX/

# Install OptiX
ubuntu@bristollz:~$ cd OptiX/
ubuntu@bristollz:~/OptiX$ sh NVIDIA-OptiX-SDK-6.0.0-linux64-25650775.sh
Do you accept the license? [yN]: 
y
By default the NVIDIA OptiX will be installed in:
  "/home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64"
Do you want to include the subdirectory NVIDIA-OptiX-SDK-6.0.0-linux64?
Saying no will install in: "/home/ubuntu/OptiX" [Yn]: 
y

Using target directory: /home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64
Extracting, please wait...

Unpacking finished successfully

# Verify OptiX
ubuntu@bristollz:~/OptiX$ cd NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples/
ubuntu@bristollz:~/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples$ export LD_LIBRARY_PATH=.:+:${LD_LIBRARY_PATH}
ubuntu@bristollz:~/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples$ ./optixHello --file hello.pbm
ubuntu@bristollz:~/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples$ sudo apt install imagemagick
ubuntu@bristollz:~/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples$ display hello.pbm 
# Alternatively, just run ./optixHello
# Now verify all examples
# Note, need --nopbo due to using TESLA GPU which does not have and openGL driver
ubuntu@bristollz:~/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples$ for sample in optix* prime*; do echo "==== $sample ===="; ./$sample --nopbo; done
```
The system will need to be rebooted after this
```code
ubuntu@bristollz:~$ sudo reboot
```
## Install Opticks
Much of this information is available from https://simoncblyth.bitbucket.io/opticks/docs/opticks.html.
Additional information can be found at https://github.com/63990/opticks-install
A large portion of the dependencies can be installed via opticks, including cmake.
To install opticks you have to be root.

### Important notes before installing
Many of the issues which you will face during installation are already documented in `notes/issues/` of opticks.
Other issues are listed at https://groups.io/g/opticks/topics.

These instructions are for opticks 34ae815 https://bitbucket.org/simoncblyth/opticks/commits/34ae8159469901b1d513aaddc61921a11608263b

If you are already familiar with opticks, follow the quick guide [here](quick_start_guide.md)
### Opticks instructions
Using the opticks functions to build/install things is not always error free. 
It may also gloss over errors so it is best to have a directory of logs.
```code
ubuntu@bristollz:~$ mkdir opticks_build_logs
```

Opticks requires being root, so set root password
```code
# Set root password
ubuntu@bristollz:~$ sudo passwd root

# Login as root
ubuntu@bristollz:~$ su
```

Now as root add the additions from ubuntu user to root .bashrc.
As many of the opticks tests are run NOT interactively, .bashrc is called multiple times, therefore the sourcing should be one of the first things in the script.
```code
# opticks source script
source /home/ubuntu/custom_opticks_setup.sh
```

Now create custom_opticks_setup.sh and fill it with the following
```code
# CUDA Path
export PATH=/usr/local/cuda-10.1/bin:/usr/local/cuda-10.1/NsightCompute-2019.1${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.1/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# NVidia OptiX Path
export LD_LIBRARY_PATH=/home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
```

Now can start with opticks.
```code
# Install mercurial
root@bristollz:/home/ubuntu# apt-get install mercurial

# Clone opticks
root@bristollz:/home/ubuntu# hg clone http://bitbucket.org/simoncblyth/opticks

# Checkout which version we need
root@bristollz:/home/ubuntu# cd opticks/
root@bristollz:/home/ubuntu/opticks# hg checkout <commit hash>
```

Edit custom_opticks_setup.sh with the following to make interacting with opticks simpler.
These have been changed from $HOME to /home/ubuntu as HOME for root is different.
This is taken from the opticks installation guide (linked at the start of this section).
This may need to be updated, see custom_opticks_setup.sh
```code
# Make opticks easier to interact with
opticks-(){ . /home/ubuntu/opticks/opticks.bash && opticks-env $* ; }
opticks-

export LOCAL_BASE=/usr/local
export OPTICKS_HOME=/home/ubuntu/opticks
op(){ op.sh $* ; }

export PYTHONPATH=/home/ubuntu
export PATH=$LOCAL_BASE/opticks/lib:$OPTICKS_HOME/bin:$OPTICKS_HOME/ana:$PATH
```
Now rerun .bashrc to get opticks functions.

Now it is possible to check if the environment is set up correctly. 
We can see that cmake is missing.
```code
root@bristollz:/home/ubuntu# bash -ic "opticks- ; opticks-info "

Command 'cmake' not found, but can be installed with:

sudo apt install cmake

opticks-externals-info
============================

    opticks-cmake-version  : 


opticks-locations
==================

      opticks-source   :   /home/ubuntu/opticks/opticks.bash
      opticks-home     :   /home/ubuntu/opticks
      opticks-name     :   opticks

      opticks-fold     :   /usr/local/opticks

      opticks-sdir     :   /home/ubuntu/opticks
      opticks-idir     :   /usr/local/opticks
      opticks-bdir     :   /usr/local/opticks/build
      opticks-xdir     :   /usr/local/opticks/externals
      ## cd to these with opticks-scd/icd/bcd/xcd

      opticks-installcachedir   :  /usr/local/opticks/installcache
      opticks-bindir            :  /usr/local/opticks/lib
      opticks-optix-install-dir :  /usr/local/opticks/externals/OptiX


       uname   : Linux bristollz 4.15.0-1013-oracle #15-Ubuntu SMP Wed May 8 15:10:28 UTC 2019 x86_64 x86_64 x86_64 GNU/Linux
       HOME    : /home/ubuntu
       VERBOSE : 
       USER    : ubuntu

OPTICKS_HOME=/home/ubuntu/opticks
opticks-externals-url
                           bcm :  http://github.com/simoncblyth/bcm.git 
                           glm :  https://github.com/g-truc/glm/releases/download/0.9.9.5/glm-0.9.9.5.zip 
                          glfw :  http://downloads.sourceforge.net/project/glfw/glfw/3.1.1/glfw-3.1.1.zip 
opticks-cmake-generator: command not found
                          glew :  http://downloads.sourceforge.net/project/glew/glew/1.13.0/glew-1.13.0.zip 
                          gleq :  https://github.com/simoncblyth/gleq 
                         imgui :  http://github.com/simoncblyth/imgui.git 
                        assimp :  http://github.com/simoncblyth/assimp.git 
                      openmesh :  http://www.openmesh.org/media/Releases/6.3/OpenMesh-6.3.tar.gz 
                          plog :  https://github.com/simoncblyth/plog 
                   opticksdata :  http://bitbucket.org/simoncblyth/opticksdata 
               oimplicitmesher :  https://bitbucket.com/simoncblyth/ImplicitMesher 
                          odcs :  https://github.com/simoncblyth/DualContouringSample 
                      oyoctogl :  https://github.com/simoncblyth/yocto-gl 
                       ocsgbsp :  https://github.com/simoncblyth/csgjs-cpp 
                       xercesc :  http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-3.1.1.tar.gz 
                            g4 :  http://geant4-data.web.cern.ch/geant4-data/releases/geant4.10.04.p02.tar.gz 
opticks-externals-dist
                           bcm :   
                           glm :  /usr/local/opticks/externals/glm/glm-0.9.9.5.zip 
                          glfw :  /usr/local/opticks/externals/glfw/glfw-3.1.1.zip 
                          glew :  /usr/local/opticks/externals/glew/glew-1.13.0.zip 
                          gleq :   
                         imgui :   
                        assimp :   
                      openmesh :  /usr/local/opticks/externals/openmesh/OpenMesh-6.3.tar.gz 
                          plog :   
                   opticksdata :   
               oimplicitmesher :   
                          odcs :   
                      oyoctogl :   
                       ocsgbsp :   
                       xercesc :  xerces-c-3.1.1.tar.gz 
                            g4 :  /usr/local/opticks/externals/g4/geant4.10.04.p02.tar.gz 
opticks-optionals-url
opticks-optionals-dist
```

Now install cmake
```code
# Run precursor functions
root@bristollz:/home/ubuntu# opticks-
root@bristollz:/home/ubuntu# ocmake-

# Remove old cmake
# Note these will remove... grub-pc-bin* libnvidia-common-430* which is fine
root@bristollz:/home/ubuntu# sudo apt purge --auto-remove cmake


# See what version ocmake will install (this can also be done by looking in the bash function by ocmake-vi
root@bristollz:/home/ubuntu# ocmake-info
ocmake-info
============

ocmake-vers : 3.14.1
ocmake-nam  : cmake-3.14.1
ocmake-url  : https://github.com/Kitware/CMake/releases/download/v3.14.1/cmake-3.14.1.tar.gz
ocmake-dir  : /usr/local/opticks/externals/cmake/cmake-3.14.1

# Install cmake
root@bristollz:/home/ubuntu# ocmake--
```

Alternatively, install cmake outside of opticks and not as root
```code
ubuntu@bristollz:~$ mkdir software
ubuntu@bristollz:~$ cd software/
ubuntu@bristollz:~/software$ git clone https://gitlab.kitware.com/cmake/cmake.git
ubuntu@bristollz:~/software$ cd cmake/
ubuntu@bristollz:~/software/cmake$ git checkout tags/<version>
ubuntu@bristollz:~/software/cmake$ ./bootstrap && make && sudo make install
```

Now check cmake
```code
# Check cmake is default
ubuntu@bristollz:~/software/cmake$ which cmake
/usr/local/bin/cmake
ubuntu@bristollz:~$ cmake --version
cmake version 3.14.5

CMake suite maintained and supported by Kitware (kitware.com/cmake).

# Check cmake is using opticks
root@bristollz:~# opticks-info
opticks-externals-info
============================

    opticks-cmake-version  : 3.14.1
```

Now get boost.
```code
root@bristollz:~# opticks-
root@bristollz:~# boost-
root@bristollz:~# boost--

# Or if that fails (which it shouldn't)
ubuntu@bristollz:~$ sudo apt-get install libboost-all-dev
```
### Install Opticks externals
Install opticks externals
```code
# These are the externals which will be installed
root@bristollz:~# opticks-externals
bcm
glm
glfw
glew
gleq
imgui
assimp
openmesh
plog
opticksdata
oimplicitmesher
odcs
oyoctogl
ocsgbsp
xercesc
g4

root@bristollz:~# opticks-optionals-install # don't think this actually does anything but opticks docs says do it

# require unzip
root@bristollz:~# apt-get install unzip

# In custom_opticks_setup.sh add opticks-cmake-generator
root@bristollz:/home/ubuntu# cat !$
cat custom_opticks_setup.sh
opticks-cmake-generator(){ echo ${OPTICKS_CMAKE_GENERATOR:-Unix Makefiles} ; }
root@bristollz:/home/ubuntu# source custom_opticks_setup.sh

# For glfw we need headers for glfw 
root@bristollz:/usr/local/opticks/externals/glfw# apt install libxrandr-dev
root@bristollz:/usr/local/opticks/externals/glfw# apt install libxinerama-dev
root@bristollz:/usr/local/opticks/externals/glfw# apt install -y libxcursor-dev

# edit GFindOpticksGLEW.cmake to search in lib64 (for imgui to work)
# /home/ubuntu/opticks/cmake/Modules/FindOpticksGLEW.cmake line 11 to 
# PATHS ${OpticksGLEW_PREFIX}/lib64)

# Open mesh will fail compiling using official release 6.3.
# Trying release 7.1
# edit file open /home/ubuntu/opticks/externals/openmesh.bash line 1071

# For geant4 get expat
root@bristollz:/home/ubuntu/opticks# sudo apt-get install libexpat1-dev

# Now install externals (will take a long time, G4 make will take ~1 hour)
# For when they go wrong do -wipe, eg glfw-wipe then glfw-- (which does glfw-get, glfw-cmake, gldw-make install) 
root@bristollz:~# opticks-externals-install
```

### Install Opticks-full
Now to prepare of opticks-full. 
```code
# opticks-full trys to install the following
root@bristollz:/home/ubuntu/OptiX# om-
root@bristollz:/home/ubuntu/OptiX# om-subs
okconf
sysrap
boostrap
npy
yoctoglrap
optickscore
ggeo
assimprap
openmeshrap
opticksgeo
cudarap
thrustrap
optixrap
okop
oglrap
opticksgl
ok
extg4
cfg4
okg4
g4ok
```

To get these working, we require several things

```code
# Get dev version of openssl
root@bristollz:/home/ubuntu/opticks# apt-get install libssl-dev
```

optixrap requires
```code
#To fix optixrap error, edit /home/ubuntu/opticks/cmake/Modules/FindOptiX.cmake to contain on line 41
if (DEFINED ENV{OptiX_INSTALL_DIR})
        set(OptiX_INSTALL_DIR $ENV{OptiX_INSTALL_DIR})
endif()

# edit /home/ubuntu/opticks/optixrap/CMakeLists.txt line 53 to contain
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# and edit setup script so it contain
export OptiX_INSTALL_DIR=/home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64

# Add to custom_opticks_setup.sh
# I think only CFLAGS is needed though as CXXFLAGS is already set
export CXXFLAGS="$CXXFLAGS -fPIC"
export CFLAGS="$CFLAGS -fPIC"
```

From the logs there is lpthread error. Add these to stop that?
Also it is looking for lpthreads when it should be lpthread
```code
sudo apt-get install libprotobuf-dev libleveldb-dev libsnappy-dev libopencv-dev libhdf5-serial-dev libgflags-dev libgoogle-glog-dev liblmdb-dev protobuf-compiler libatlas-base-dev
# I've removed libboost-all-dev as should be sorted out from boost--
sudo apt-get install python-dev python-pip gfortran
```

We must also set the compute capability.
Not setting this will cause OKConf and sysrap tests to fail as it's default is 0.
The compute capability of the GPU can be found at https://developer.nvidia.com/cuda-gpus.
6.1 = 61, 6.0 = 60 etc...
Add the following line to the setup script...
```code
export OPTICKS_COMPUTE_CAPABILITY=60
```

For g4ok and okg4 tests to pass we must add opticks externals to the library path.
Add this line to setup script
```code
export LD_LIBRARY_PATH=/usr/local/opticks/externals/lib${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
```

Now run optix-full
```code
opticks-full
```

### Running opticks tests
To run the opticks tests is as simple as running `opticks-t`. 
However, this will result in ~10% failures.
To pass the tests, `numpy` and `IPython` are required.
Additionally, `op.sh -G` needs to be run to load the geometry.
NOTE: There will a lot of scary looking outputs (WARNINGS, ERRORS, etc...). 
These are left over from debugging and can be ignored.

Finally, a workflow geocache needs to be created.
```code
# Setup geocache
geocache-

# Create geocache-
geocache-create
```
The command geocache-recreate loads a JUNO GDML file creating the Geant4 geometry and then translates that 
into Opticks GGeo and persists that into the geocache

In order to use this geometry, `OPTICKS_KEY` has to be set. 
This is best done in the `custom_opticks_setup.sh` script so that it is called when `tboolean.sh` is run. 
The `OPTICKS_KEY` will look something like this `OKX4Test.X4PhysicalVolume.lWorld0x4bc2710_PV.f6cc352e44243f8fa536ab483ad390ce`.
The output of geocache-create will tell you what the OPTICKS_KEY is.
The line needed in `custom_opticks_setup.sh` required is...
```code 
export OPTICKS_KEY=OKX4Test.X4PhysicalVolume.lWorld0x4bc2710_PV.f6cc352e44243f8fa536ab483ad390ce
```

A final note on the opticks tests.
When first run, 3 tests may fail.
The interpolationTest (OptixRap) will pass when run again - this is because it requires the output from a future test.
```code 
FAILS:  2   / 406   :  Thu Jul  4 11:18:00 2019   
  4  /24  Test #4  : OptiXRapTest.Roots3And4Test                   Child aborted***Exception:     0.85   
  21 /24  Test #21 : OptiXRapTest.intersectAnalyticTest.iaTorusTest Child aborted***Exception:     1.04   
```


## Using LZ geometry
To get the LZ geometry, we firstly need to get the lz geometry (a gdml file).
eg `https://lz-git.ua.edu/sim/BACCARAT/-/jobs/54378/artifacts/file/output/geometry.gdml`
Alternatively, in the LZ software docs there are instructions on getting geometry gdml file from a BACCARAT macro command.

Get this on the gpu instance under `/home/ubuntu/LZ/lz_geometry.gdml`

Now comment out the OPTICKS_KEY as this refers to the wrong geometry.

Now we must convert this into GPU compatable numpy.
We should be able to do this via `geocache-` functions, however for testing purposes we can skip the middle man and just do ...
` o.sh --okx4 --g4codegen --deletegeocache --gdmlpath /home/ubuntu/LZ/lz_geometry.gdml -D`.
THe `-D` is for debug.

This just runs `OKX4Test --g4codegen --deletegeocache --gdmlpath /home/ubuntu/LZ/lz_geometry.gdml -D` so this can be done instead
