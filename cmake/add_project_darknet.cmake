# darknet External Project
#
# Required symbols are:
#   VIAME_BUILD_PREFIX - where packages are built
#   VIAME_BUILD_INSTALL_PREFIX - directory install target
#   VIAME_PACKAGES_DIR - location of git submodule packages
#   VIAME_ARGS_COMMON -
##

set( VIAME_PROJECT_LIST ${VIAME_PROJECT_LIST} darknet )

if( WIN32 )
  set( DARKNET_BUILD_SHARED OFF )
else()
  set( DARKNET_BUILD_SHARED ON )
endif()

if( VIAME_ENABLE_CUDA )
  FormatPassdowns( "CUDA" VIAME_DARKNET_CUDA_FLAGS )
  set( VIAME_DARKNET_CUDA_FLAGS 
    ${VIAME_DARKNET_CUDA_FLAGS}
    -DCUDA_TOOLKIT_ROOT_DIR:PATH=${CUDA_TOOLKIT_ROOT_DIR}
    -DCMAKE_LIBRARY_PATH:PATH=${CUDA_TOOLKIT_ROOT_DIR}/lib64/stubs )
endif()

if( VIAME_ENABLE_CUDNN )
  FormatPassdowns( "CUDNN" VIAME_DARKNET_CUDNN_FLAGS )
endif()

if(VIAME_FORCE_CUDA_CSTD98)
  set( DARKNET_CXXFLAGS_OVERRIDE
    -DCMAKE_CXX_FLAGS=-std=c++98 )
else()
  set( DARKNET_CXXFLAGS_OVERRIDE )
endif()

ExternalProject_Add(darknet
  DEPENDS fletch
  PREFIX ${VIAME_BUILD_PREFIX}
  SOURCE_DIR ${VIAME_PACKAGES_DIR}/darknet
  USES_TERMINAL_BUILD 1
  CMAKE_GENERATOR ${gen}
  CMAKE_CACHE_ARGS
    ${VIAME_ARGS_COMMON}
    ${VIAME_ARGS_fletch}
    ${VIAME_DARKNET_CUDA_FLAGS}
    ${VIAME_DARKNET_CUDNN_FLAGS}
    ${DARKNET_CXXFLAGS_OVERRIDE}
    -DBUILD_SHARED_LIBS:BOOL=${DARKNET_BUILD_SHARED}
    -DUSE_GPU:BOOL=${VIAME_ENABLE_CUDA}
    -DUSE_CUDNN:BOOL=${VIAME_ENABLE_CUDNN}
    -DBUILD_EXAMPLES:BOOL=ON
    -DINSTALL_HEADER_FILES:BOOL=ON
    -DUSE_OPENCV:BOOL=OFF
  INSTALL_DIR ${VIAME_BUILD_INSTALL_PREFIX}
  )

if ( VIAME_FORCEBUILD )
ExternalProject_Add_Step(darknet forcebuild
  COMMAND ${CMAKE_COMMAND}
    -E remove ${VIAME_BUILD_PREFIX}/src/darknet-stamp/darknet-build
  COMMENT "Removing build stamp file for build update (forcebuild)."
  DEPENDEES configure
  DEPENDERS build
  ALWAYS 1
  )
endif()

set(VIAME_ARGS_darknet
  -Ddarknet_DIR:PATH=${VIAME_BUILD_PREFIX}/src/darknet-build
  )
