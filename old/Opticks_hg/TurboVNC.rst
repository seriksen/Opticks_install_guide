*************
Desktop Setup
*************
Opticks requires OpenGL 4.0 or greater.
Using GPU in compute mode (which is how they are in clusters) means that there isn't any hardware acceleration.
We can get around this using virtualGL and turboVNC.
These require the NVIDIA grid GPU version (see NVIDIA_Externals)

.. code-block:: sh

    sudo init 3
    sudo passwd opc
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

