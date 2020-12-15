# Use to skip installation bits up to opticks-full

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
            curl-devel \
            openssl-devel

export OPTICKS_EXTERNALS=/home/opc/opticks_externals

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
./b2 --prefix=${dir}/${boost_name}-install --build-dir=${dir}/${boost_name}-build --with-system --with-thread --with-program_options --with-log --with-filesystem --with-regex install


clhep_version=2.4.1.0
url=http://proj-clhep.web.cern.ch/proj-clhep/DISTRIBUTION/tarFiles/clhep-${clhep_version}.tgz
dir=${OPTICKS_EXTERNALS}/clhep
mkdir -p $dir
cd $dir
curl -L -O $url
tar zxf $(basename $url)
mkdir clhep_${clhep_version}-build
cd clhep_${clhep_version}-build
cmake -DCMAKE_INSTALL_PREFIX=${dir}/clhep_${clhep_version}-install ../${clhep_version}/CLHEP
make -j 10
sudo make install


xerces_version=3.1.1
url=http://archive.apache.org/dist/xerces/c/3/sources/xerces-c-${xerces_version}.tar.gz
dir=${OPTICKS_EXTERNALS}/xerces
mkdir -p $dir
cd $dir
curl -L -O $url
tar zxf $(basename $url)
cd xerces-c-${xerces_version}
./configure --prefix=${dir}/xerces-c-${xerces_version}-install
sudo make install

g4_version=geant4.10.06.p02
dir=${OPTICKS_EXTERNALS}/g4
mkdir -p ${dir}
cd ${dir}
url=http://cern.ch/geant4-data/releases/${g4_version}.tar.gz
curl -L -O $url
tar zxf ${g4_version}.tar.gz
mkdir ${g4_version}-build
cd ${g4_version}-build
cmake -G "Unix Makefiles" \
      -DCMAKE_BUILD_TYPE=Debug \
      -DGEANT4_INSTALL_DATA=ON \
      -DGEANT4_USE_GDML=ON \
      -DGEANT4_USE_SYSTEM_CLHEP=ON \
      -DCLHEP_ROOT_DIR=/home/opc/opticks_externals/clhep/clhep_2.4.1.0-install \
      -DGEANT4_INSTALL_DATA_TIMEOUT=3000 \
      -DXERCESC_ROOT_DIR=/home/opc/opticks_externals/xerces/xerces-c-${xerces_version}-install \
      -DCMAKE_INSTALL_PREFIX=${dir}/${g4_version}-install \
      ${dir}/${g4_version}
make -j 10
make install
