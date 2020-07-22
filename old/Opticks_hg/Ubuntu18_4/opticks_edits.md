# Opticks edits
## For externals
```code
# edit GFindOpticksGLEW.cmake to search in lib64 (for imgui to work)
# /home/ubuntu/opticks/cmake/Modules/FindOpticksGLEW.cmake line 11 to 
# PATHS ${OpticksGLEW_PREFIX}/lib64)

# Open mesh will fail compiling using official release 6.3.
# Trying release 7.1
# edit file open /home/ubuntu/opticks/externals/openmesh.bash line 1071
```

## For opticks
```code
# For optixrap 
# edit /home/ubuntu/opticks/cmake/Modules/FindOptiX.cmake to contain on line 41
if (DEFINED ENV{OptiX_INSTALL_DIR})
        set(OptiX_INSTALL_DIR $ENV{OptiX_INSTALL_DIR})
endif()

# edit /home/ubuntu/opticks/optixrap/CMakeLists.txt line 53 to contain
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
```