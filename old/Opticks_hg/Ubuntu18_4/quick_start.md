# Quick Start
Listed below are the steps to get opticks to run (assuming optiX and cuda are installed with the correct GPU driver)

1. Create `custom_opticks_setup.sh` script
1. Edit .bashrc to `source custom_opticks_setup.sh` before .bashrc edits early
1. Install libraries
1. Edit opticks file to find the correct libraries (eg lib64 vs lib)
1. Install cmake and boost
1. Install opticks externals
1. Install opticks
1. Runn opticks install tests

You can find `custom_opticks_setup.sh` [here](custom_opticks_setup.sh)

The libraries required are [here](libraries_to_install_opticks_only.sh)

The edits are listed [here](opticks_edits.md)

Install cmake and boost by the following
```code
opticks-
ocmake-
ocmake--
boost-
boost--
```

Install opticks externals by the following
```code
opticks-
opticks-optionals-install 
opticks-externals-install
```

Install opticks
```code
opticks-
opticks-full
```

Run tests (note, need to have the geometry setup OPTICKS_KEY)
```code
opticks-
opticks-t
```