*************
Desktop Setup
*************
Opticks requires OpenGL 4.0 or greater.
Using GPU in compute mode (which is how they are in clusters) means that there isn't any hardware acceleration.
We can get around this using virtualGL and turboVNC.
These require the NVIDIA grid GPU version (see NVIDIA_Externals)

.. code-block:: sh

    sudo init 3
    sudo passwd opc # EggyBread
    sudo yum -y install https://downloads.sourceforge.net/project/virtualgl/2.6.3/VirtualGL-2.6.3.x86_64.rpm
    sudo yum -y install gdm
    sudo yum -y install https://downloads.sourceforge.net/project/turbovnc/2.2.4/turbovnc-2.2.4.x86_64.rpm
    sudo yum -y groupinstall "X Window System"
    sudo yum -y groupinstall "Xfce"
    sudo nvidia-xconfig -a --allow-empty-initial-configuration --virtual=1920x1200 --busid PCI:0:4:0
    sudo vglserver_config -config +s +f -t
    sudo systemctl restart gdm
    export DISPLAY=:1
    /opt/TurboVNC/bin/vncserver --help
    /opt/TurboVNC/bin/vncserver -vgl -wm xfce4-session
    sudo firewall-cmd --zone=public --permanent --add-port=5901/tcp
    sudo firewall-cmd --reload

Kill turbo vnc by :code:`/opt/TurboVNC/bin/vncserver -kill :1`

TODO: Add OTP


When instance has been restarted openGL isn't working so restart gdm.
But I'm always doing...

.. code-block:: sh

    sudo nvidia-xconfig -a --allow-empty-initial-configuration --virtual=1920x1200 --busid PCI:0:4:0
    export DISPLAY=:1
    sudo systemctl restart gdm
    /opt/TurboVNC/bin/vncserver -vgl -wm xfce4-session

Log in and test

.. code-block:: sh

    [opc@vgl-test-321891 ~]$ glxinfo | grep -i opengl
    OpenGL vendor string: NVIDIA Corporation
    OpenGL renderer string: Tesla P100-SXM2-16GB/PCIe/SSE2
    OpenGL core profile version string: 4.6.0 NVIDIA 440.56
    OpenGL core profile shading language version string: 4.60 NVIDIA
    OpenGL core profile context flags: (none)
    OpenGL core profile profile mask: core profile
    OpenGL core profile extensions:
    OpenGL version string: 4.6.0 NVIDIA 440.56
    OpenGL shading language version string: 4.60 NVIDIA
    OpenGL context flags: (none)
    OpenGL profile mask: (none)
    OpenGL extensions:
    OpenGL ES profile version string: OpenGL ES 3.2 NVIDIA 440.56
    OpenGL ES profile shading language version string: OpenGL ES GLSL ES 3.20
    OpenGL ES profile extensions:


It's interesting to note that on Bristol's machine the turboVNC terminal was very slow to run glxinfo (30mins+) and
never managed to load glxgears.
A better approach I found was to connect to the machine using vglconnect, set :code:`DISPLAY=:1` then run things via that
connection as the output will appear on what you see on turboVNC.