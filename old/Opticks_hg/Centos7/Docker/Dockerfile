#Using Centos7 and CUDA 10.1
FROM nvidia/cuda:10.1-cudnn7-devel-centos7
ENV CUDA_VERSION=10.1
ENV CUDA_SUBVERSION=.243-1
ENV NsightCompute_version=2019.1

## comment the above and replace with this for version 11
#FROM nvidia/cuda:11.0-cudnn7-devel-centos7
#ENV CUDA_VERSION=11.0
#ENV CUDA_SUBVERSION=.3-1
#ENV NsightCompute_version=2019.3

# prepare installation setup for yum and sudo
RUN yum -y update
RUN yum -y install sudo

#set up dependencies for installation processes
RUN sudo yum -y install xorg-x11-apps.x86_64\
	xauth \
	pciutils \
	lshw \
	epel-release \
	wget

# Set environment Variables for Dockerfile
ENV NVIDIA_DRIVER=nvidia-diag-driver-local-repo-rhel7-418.67-1.0-1.x86_64.rpm
ENV CUDA_RPM=cuda-repo-rhel7-10.1.168-1.x86_64.rpm
ENV CUDA_URL=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/${CUDA_RPM}
ENV CUDA_KEY=http://developer.download.nvidia.com/compute/cuda/repos/rhel7/x86_64/7fa2af80.pub

#Install NVIDIA Drivers
ENV OptixVersion NVIDIA-OptiX-SDK-6.0.0-linux64-25650775
ENV OptixInstall ${OptixVersion}.sh

#Set install directories
ENV INSTALL_BASE /usr/local
ENV CUDA_SAMPLES_DIR ${INSTALL_BASE}/cuda-samples

#Copy the NVIDIA Drivers to the image
COPY ${NVIDIA_DRIVER} /tmp

#Install the NVIDIA Drivers
RUN sudo rpm -i /tmp/$NVIDIA_DRIVER

#Setup for CUDA install
RUN sudo yum clean all
RUN sudo yum -y install cuda-drivers

#Get CUDA from the URL
RUN sudo wget ${CUDA_URL}
RUN sudo wget -O ~/cuda_key "${CUDA_URL}"
#RUN rpm --import ~/cuda_key.pub
RUN sudo rpm -i ${CUDA_RPM}
RUN sudo yum clean all
RUN sudo yum -y install cuda-${CUDA_VERSION}${CUDA_SUBVERSION}

#install various dependencies
RUN sudo yum install -y freeglut-devel \
	libX11-devel \
	libXi-devel \
	libXmu-devel \
	make \
	mesa-libGLU-devel \
	ImageMagick \
	ImageMagick-devel \
	git 
#	cmake3 

#install cuda
RUN  mkdir ${CUDA_SAMPLES_DIR} && cd ${CUDA_SAMPLES_DIR}

#sets cuda related environment variables
ENV PATH="/usr/local/cuda-${CUDA_VERSION}/bin:/usr/local/cuda-${CUDA_VERSION}/NsightCompute-${NsightCompute_version}${PATH:+:${PATH}}"
ENV LD_LIBRARY_PATH="/usr/local/cuda-${CUDA_VERSION}/lib64${LD_LIRARY_PATH:+:${LD_LIBRARY_PATH}}"
ENV LD_LIBRARY_PATH="/opt/${OptixVersion}/SDK-precompiled-samples/:+:${LD_LIBRARY_PATH}"

#installs cuda samples for testing purposes
RUN cuda-install-samples-${CUDA_VERSION}.sh .
RUN cd /NVIDIA_CUDA-${CUDA_VERSION}_Samples/0_Simple/simpleAssert && make 
#RUN cd /NVIDIA_CUDA-11.0_Samples/0_Simple/simpleAssert && ./simpleAssert 

#Now install Opticks
RUN sudo yum install -y mercurial && \
	cd ${INSTALL_BASE} && \
	hg clone http://bitbucket.org/simoncblyth/opticks_hg && \
	mv opticks_hg opticks && \
	cd opticks && \
	hg checkout 1e25685
#RUN cd ${INSTALL_BASE} && \
#	git clone https://bitbucket.org/simoncblyth/opticks.git



#Install OptiX
ENV OPTIX_DIR ${INSTALL_BASE}/OptiX
RUN mkdir $OPTIX_DIR
COPY ${OptixInstall} $OPTIX_DIR

RUN cd $OPTIX_DIR && yes | bash ${OptixInstall} --prefix=${INSTALL_BASE}/OptiX


#Add necessary elements to the bashrc script
RUN echo "# opticks source script" >> /root/.bashrc \
	&& echo "source ${INSTALL_BASE}/custom_opticks_setup.sh" >> /root/.bashrc

#Copies the custop setup script to the image
COPY custom_opticks_setup.sh ${INSTALL_BASE}/custom_opticks_setup.sh

#Sets the default shell to bash
SHELL ["/bin/bash", "-c"]

#Makes Opticks
RUN source /root/.bashrc \
	&& opticks- \
	&& ocmake- \
	&& ocmake-info \
	&& ocmake--

#link cmake3 to cmake (this is a change)
#RUN ln -s /usr/bin/cmake3 /usr/bin/cmake

#install boost
RUN source /root/.bashrc \
	&& opticks- \
	&& boost- \
	&& boost--

#Install Opticks optionals components
RUN source /root/.bashrc \
        && opticks-optionals-install

#Install some more dependencies
RUN sudo yum install -y \
        libXcursor-devel libXinerama-devel libXrandr-devel \
        mesa-dri-drivers mesa-libGLES mesa-libGLw mesa-libGLw-devel \
        freeglut-devel freeglut expat-devel \
        doxygen \
        mercurial \
	git \
	zip unzip

#Install CMAKE
RUN cd ${INSTALL_BASE}/opticks/externals/cmake/cmake-3.14.1/ \
	&& ./bootstrap --prefix=/usr \
	&& make \
	&& sudo make install

#Sets some environment variables
ENV CHLEP_DIR="/usr/local/opticks_externals/clhep/lib/CLHEP-2.4.1.0/"
ENV export OPTICKS_INSTALL_PREFIX="${INSTALL_BASE}/opticks/"
ENV export OPTICKS_OPTIX_PREFIX=$(opticks-optix-install-dir)
#RUN echo "#In custom_opticks_setup.sh add opticks-cmake-generator" >> /custom_opticks_setup.sh \
#	&& echo "opticks-cmake-generator(){ echo ${OPTICKS_CMAKE_GENERATOR:-Unix Makefiles} ; }" >> /custom_opticks_setup.sh \
#	&& echo "export OPTICKS_INSTALL_PREFIX=/opticks" >> /custom_opticks_setup.sh  \
#	&& echo "OptiX_INSTALL_DIR=/home/opc/OptiX/NVIDIA-OptiX-SDK-6.0.0-linux64" >> /custom_opticks_setup.sh  
	
#installs pip and numpy
RUN sudo yum install -y openssl-devel python-pip \
	&& pip install --upgrade pip \
	&& sudo pip install numpy


#Prepare to run opticks tests. We need the following libraries
RUN sudo yum install -y python-devel python-pip ipython \
        libcanberra-gtk2 # for tboolean

##To fix optixrap error, edit /home/opc/opticks/cmake/Modules/FindOptiX.cmake to contain on line 41
RUN  sed -i '/^macro(OPTIX_find_api_library name version)/i #To fix optixrap error, edit \/home\/opc\/opticks\/cmake\/Modules\/FindOptiX.cmake to contain on line 41' \
	/usr/local/opticks/cmake/Modules/FindOptiX.cmake && \
sed -i '/^macro(OPTIX_find_api_library name version)/i  if (DEFINED ENV{OptiX_INSTALL_DIR})' \
	/usr/local/opticks/cmake/Modules/FindOptiX.cmake &&\
sed -i '/^macro(OPTIX_find_api_library name version)/i          set(OptiX_INSTALL_DIR $ENV{OptiX_INSTALL_DIR})'\
	 /usr/local/opticks/cmake/Modules/FindOptiX.cmake &&\
sed -i '/^macro(OPTIX_find_api_library name version)/i  endif()' \
	/usr/local/opticks/cmake/Modules/FindOptiX.cmake

# Change to openmesh 7.1 and
# edit FindOpticksGLEW.cmake to search in lib64 (for imgui to work)
# /home/opc/opticks/cmake/Modules/FindOpticksGLEW.cmake line 20 to
RUN sed -i 's/PATHS \${OpticksGLEW_PREFIX}\/lib )/PATHS \${OpticksGLEW_PREFIX}\/lib64)/g' /usr/local/opticks/cmake/Modules/FindOpticksGLEW.cmake && \
        sed -i 's/openmesh-vers(){ echo 6.3 ; }/#openmesh-vers(){ echo 6.3 ; }/g' /usr/local/opticks/externals/openmesh.bash && \
	sed -i '/^#openmesh-vers(){ echo 6.3 ; }/a openmesh-vers(){ echo 7.1 ; }' /usr/local/opticks/externals/openmesh.bash


#Installs opticks-externals
RUN source /root/.bashrc \
        && opticks-externals-install


#Install debugging software
RUN debuginfo-install -y expat-2.1.0-10.el7_3.x86_64 \
                  glibc-2.17-260.el7_6.6.x86_64 \
                  keyutils-libs-1.5.8-3.el7.x86_64 \
                  krb5-libs-1.15.1-37.el7_6.x86_64 \
                  libX11-1.6.5-2.el7.x86_64 \
                  libXau-1.0.8-2.1.el7.x86_64 \
                  libXcursor-1.1.15-1.el7.x86_64 \
                  libXext-1.3.3-3.el7.x86_64 \
                  libXfixes-5.0.3-1.el7.x86_64 \
                  libXi-1.7.9-1.el7.x86_64 \
                  libXinerama-1.1.3-2.1.el7.x86_64 \
                  libXrandr-1.5.1-2.el7.x86_64 \
                  libXrender-0.9.10-1.el7.x86_64 \
                  libXxf86vm-1.1.4-1.el7.x86_64 \
                  libcom_err-1.42.9-13.el7.x86_64 \
                  libgcc-4.8.5-36.el7_6.2.x86_64 \
                  libglvnd-1.0.1-0.8.git5baa1e5.el7.x86_64 \
                  libglvnd-glx-1.0.1-0.8.git5baa1e5.el7.x86_64 \
                  libselinux-2.5-14.1.el7.x86_64 \
                  libstdc++-4.8.5-36.el7_6.2.x86_64 \
                  libxcb-1.13-1.el7.x86_64 \
                  openssl-libs-1.0.2k-16.el7_6.1.x86_64 \
                  pcre-8.32-17.el7.x86_64 \
                  zlib-1.2.7-18.el7.x86_64 \
		  krb5-libs-1.15.1-37.el7_7.2.x86_64 \
		  libcom_err-1.42.9-16.el7.x86_64 \
		  openssl-libs-1.0.2k-19.el7.x86_64


#installs and configures imgui and glfw
RUN source /root/.bashrc\
        && glfw- \
        && glfw-cmake \
        && glfw-config \
        && glfw-configure \
        && glfw-- \
        && imgui- \
        && imgui-configure \
        && imgui--  \
        && opticks-externals-install \
	&& ln -s $OptiX_INSTALL_DIR /usr/local/opticks/externals/OptiX \
        &&  opticks-full
