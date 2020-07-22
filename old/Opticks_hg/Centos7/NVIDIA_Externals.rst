***********************
NVIDIA GPU Setup
***********************

This page contains information on how to set up a system with an NVIDIA GPU with OptiX using virtualGL and turboVNC.
These instructions have been written for and tested on an oracle cloud instance (VM.GPU2.1).

System information and installation;

* Tesla P100 GPU
* NVIDIA Grid
* cuda 11
* OptiX 6.0

.. contents:: Contents

Nvidia Driver
-------------
For some reason I could only get this to work using the NVIDIA grid license so that what this section talks about.

First, check the GPU you have.
On this machine, it is a Tesla P100.

.. code-block:: sh

    [opc@bristollz ~]$ lspci | grep NVIDIA
    00:04.0 3D controller: NVIDIA Corporation GP100GL [Tesla P100 SXM2 16GB] (rev a1)

Now check what driver is installed and being used by the GPU.
We can see that `nouveau` is the driver.
We must disable this and use the NVidia one.

.. code-block:: sh

    [opc@bristollz ~]$ sudo lshw -numeric -C display | grep -i configuration
        configuration: driver=bochs-drm latency=0
        configuration: driver=nouveau latency=0

Get the driver and install things

.. code-block:: sh
    wget https://objectstorage.us-ashburn-1.oraclecloud.com/n/hpc/b/grid-drivers/o/NVIDIA-Linux-x86_64-440.56-grid.run
    sudo yum -y install gcc
    chmod a+x NVIDIA-Linux-x86_64-440.56-grid.run
    sudo yum -y install kernel-devel-$(uname -r)
    sudo yum -y install xorg-x11-drivers.x86_64

Disable nouveau by :code:`sudo vim /etc/default/grub` and add :code:`rd.driver.blacklist=nouveau nouveau.modeset=0` to
the end of the line.
Then do.

.. code-block:: sh

    # echo blacklist nouveau | sudo tee /etc/modprobe.d/blacklist.conf <- didn't actually do this bit
    # sudo vim /etc/default/grub
    sudo grub2-mkconfig -o /boot/efi/EFI/centos/grub.cfg
    sudo reboot


Then check that the driver has been removed.
Note that there is no driver now.

.. code-block:: sh

    [opc@bristollz ~]$ sudo lshw -numeric -C display | grep -i configuration
        configuration: driver=bochs-drm latency=0
        configuration: latency=0

Install grid driver

.. code-block:: sh

    sudo ./NVIDIA-Linux-x86_64-440.56-grid.run # accept license
    sudo mv /etc/nvidia/gridd.conf.template  /etc/nvidia/gridd.conf
    sudo vim /etc/nvidia/gridd.conf # Add license server and change GPU mode to 2


Can also check by :code:`nvidia-smi`

Nvidia Cuda
-----------
Cuda 11

.. code-block:: sh

    wget http://developer.download.nvidia.com/compute/cuda/11.0.1/local_installers/cuda-repo-rhel7-11-0-local-11.0.1_450.36.06-1.x86_64.rpm
    sudo rpm -i cuda-repo-rhel7-11-0-local-11.0.1_450.36.06-1.x86_64.rpm
    sudo yum clean all
    sudo yum -y install nvidia-driver-latest-dkms cuda
    sudo yum -y install cuda-drivers

TODO: Add test

Nvidia OptiX
------------
To get OptiX requires an account with the NVIDIA developer program https://developer.nvidia.com/optix.
An account is free.
Once you have an account, download the bash script from the address above.
Here are the instructions for OptiX 6.0.
Upload/download to oci instance.
Now run the script to install the instance.

.. code-block:: sh

    # Install OptiX
    [opc@bristollz OptiX]$ sh NVIDIA-OptiX-SDK-6.0.0-linux64-25650775.sh
    Do you accept the license? [yN]:
    y
    By default the NVIDIA OptiX will be installed in:
    "/home/ubuntu/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64"
    Do you want to include the subdirectory NVIDIA-OptiX-SDK-6.0.0-linux64?
    Saying no will install in: "/home/opc/OptiX" [Yn]:
    y

    Using target directory: /home/opc/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64
    Extracting, please wait...

    Unpacking finished successfully

Now verify the installation

.. code-block:: sh

    # Verify OptiX
    cd NVIDIA-OptiX-SDK-6.0.0-linux64/SDK-precompiled-samples/
    export LD_LIBRARY_PATH=${PWD}:+:${LD_LIBRARY_PATH}
    # if using virtualGL
    ./optixHello
    # otherwise
    ./optixHello --file hello.pbm
    sudo yum install ImageMagick ImageMagick-devel -y
    display hello.pbm