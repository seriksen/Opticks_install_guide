export OPTICKS_HOME="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"/opticks
#export OPTICKS_GEANT4_HOME="$G4_INSTALL_DIR"
export OPTICKS_OPTIX_INSTALL_DIR="/opt/Optix"
export OPTICKS_COMPUTE_CAPABILITY=61
export XERCESC_INCLUDE_DIR=/usr/include/xercesc
export XERCESC_LIBRARY=/usr/lib64
export XERCESC_ROOT_DIR=/usr

opticks-(){ . $OPTICKS_HOME/opticks.bash && opticks-env $* ; }
export LOCAL_BASE=/usr/local

op(){ op.sh $* ; }

export PYTHONPATH="$(dirname $OPTICKS_HOME)"
export PATH=$LOCAL_BASE/opticks/lib:$OPTICKS_HOME/bin:$OPTICKS_HOME/ana:$PATH
export IDPATH=/usr/local/opticks/opticksdata/export/DayaBay_VGDX_20140414-1300/g4_00.96ff965744a2f6b78c24e33c80d3a4cd.dae

opticks-setup(){
opticks-prepare-installcache
op.sh -G
op.sh --gdml2gltf
}
