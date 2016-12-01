# ===================================================================================
#  The UbiTrack CMake configuration file
#
#             ** File generated automatically, do not modify **
#
#  Usage from an external project:
#    In your CMakeLists.txt, add these lines:
#
#    FIND_PACKAGE(UbiTrack REQUIRED)
#    TARGET_LINK_LIBRARIES(MY_TARGET_NAME ${UbiTrack_LIBS})
#
#    Or you can search for specific UbiTrack modules:
#
#    FIND_PACKAGE(UbiTrack REQUIRED core highgui)
#
#    If the module is found then UBITRACK_<MODULE>_FOUND is set to TRUE.
#
#    This file will define the following variables:
#      - UbiTrack_LIBS                     : The list of libraries to links against.
#      - UbiTrack_LIB_DIR                  : The directory(es) where lib files are. Calling LINK_DIRECTORIES
#                                          with this path is NOT needed.
#      - UbiTrack_INCLUDE_DIRS             : The UbiTrack include directories.
#      - UbiTrack_COMPUTE_CAPABILITIES     : The version of compute capability
#      - UbiTrack_ANDROID_NATIVE_API_LEVEL : Minimum required level of Android API
#      - UbiTrack_VERSION                  : The version of this UbiTrack build. Example: "2.4.0"
#      - UbiTrack_VERSION_MAJOR            : Major version part of UbiTrack_VERSION. Example: "2"
#      - UbiTrack_VERSION_MINOR            : Minor version part of UbiTrack_VERSION. Example: "4"
#      - UbiTrack_VERSION_PATCH            : Patch version part of UbiTrack_VERSION. Example: "0"
#
#    Advanced variables:
#      - UbiTrack_SHARED
#      - UbiTrack_CONFIG_PATH
#      - UbiTrack_LIB_COMPONENTS
#
# ===================================================================================
#
#    Windows pack specific options:
#      - UbiTrack_STATIC
#      - UbiTrack_CUDA
# Adapted from OpenCV CMake Infrastructure, git repository 05/2013
# by Ulrich Eck


if(CMAKE_VERSION VERSION_GREATER 2.6)
  get_property(UbiTrack_LANGUAGES GLOBAL PROPERTY ENABLED_LANGUAGES)
  if(NOT ";${UbiTrack_LANGUAGES};" MATCHES ";CXX;")
    enable_language(CXX)
  endif()
endif()

if(NOT DEFINED UbiTrack_STATIC)
  # look for global setting
  if(NOT DEFINED BUILD_SHARED_LIBS OR BUILD_SHARED_LIBS)
    set(UbiTrack_STATIC OFF)
  else()
    set(UbiTrack_STATIC ON)
  endif()
endif()

if(NOT DEFINED UbiTrack_CUDA)
  # if user' app uses CUDA, then it probably wants CUDA-enabled UbiTrack binaries
  if(CUDA_FOUND)
    set(UbiTrack_CUDA ON)
  endif()
endif()

if(MSVC)
  if(CMAKE_CL_64)
    set(UbiTrack_ARCH x64)
  else()
    set(UbiTrack_ARCH x86)
  endif()

  if(MSVC_VERSION EQUAL 1400)
    set(UbiTrack_RUNTIME vc8)
  elseif(MSVC_VERSION EQUAL 1500)
    set(UbiTrack_RUNTIME vc9)
  elseif(MSVC_VERSION EQUAL 1600)
    set(UbiTrack_RUNTIME vc10)
  elseif(MSVC_VERSION EQUAL 1700)
    set(UbiTrack_RUNTIME vc11)
  elseif(MSVC_VERSION EQUAL 1800)
    set(UbiTrack_RUNTIME vc12)
  elseif(MSVC_VERSION EQUAL 1900)
    set(UbiTrack_RUNTIME vc14)
  endif()
elseif(MINGW)
  set(UbiTrack_RUNTIME mingw)

  execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpmachine
                  OUTPUT_VARIABLE UBITRACK_GCC_TARGET_MACHINE
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(CMAKE_UBITRACK_GCC_TARGET_MACHINE MATCHES "64")
    set(MINGW64 1)
    set(UbiTrack_ARCH x64)
  else()
    set(UbiTrack_ARCH x86)
  endif()
endif()

if(CMAKE_VERSION VERSION_GREATER 2.6.2)
  unset(UbiTrack_CONFIG_PATH CACHE)
endif()


# the following code needs to be adapted to UbiTrack Layout
get_filename_component(UbiTrack_CONFIG_PATH "${CMAKE_CURRENT_LIST_FILE}" PATH CACHE)
if(UbiTrack_RUNTIME AND UbiTrack_ARCH)
  if(UbiTrack_STATIC AND EXISTS "${UbiTrack_CONFIG_PATH}/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/staticlib/UbiTrackConfig.cmake")
    if(UbiTrack_CUDA AND EXISTS "${UbiTrack_CONFIG_PATH}/gpu/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/staticlib/UbiTrackConfig.cmake")
      set(UbiTrack_LIB_PATH "${UbiTrack_CONFIG_PATH}/gpu/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/staticlib")
    else()
      set(UbiTrack_LIB_PATH "${UbiTrack_CONFIG_PATH}/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/staticlib")
    endif()
  elseif(EXISTS "${UbiTrack_CONFIG_PATH}/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/lib/UbiTrackConfig.cmake")
    if(UbiTrack_CUDA AND EXISTS "${UbiTrack_CONFIG_PATH}/gpu/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/lib/UbiTrackConfig.cmake")
      set(UbiTrack_LIB_PATH "${UbiTrack_CONFIG_PATH}/gpu/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/lib")
    else()
      set(UbiTrack_LIB_PATH "${UbiTrack_CONFIG_PATH}/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}/lib")
    endif()
  endif()
endif()

if(UbiTrack_LIB_PATH AND EXISTS "${UbiTrack_LIB_PATH}/UbiTrackConfig.cmake")
  set(UbiTrack_LIB_DIR_OPT "${UbiTrack_LIB_PATH}" CACHE PATH "Path where release UbiTrack libraries are located" FORCE)
  set(UbiTrack_LIB_DIR_DBG "${UbiTrack_LIB_PATH}" CACHE PATH "Path where debug UbiTrack libraries are located" FORCE)
  set(UbiTrack_3RDPARTY_LIB_DIR_OPT "${UbiTrack_LIB_PATH}" CACHE PATH "Path where release 3rdpaty UbiTrack dependencies are located" FORCE)
  set(UbiTrack_3RDPARTY_LIB_DIR_DBG "${UbiTrack_LIB_PATH}" CACHE PATH "Path where debug 3rdpaty UbiTrack dependencies are located" FORCE)

  include("${UbiTrack_LIB_PATH}/UbiTrackConfig.cmake")

  if(UbiTrack_CUDA)
    MESSAGE(STATUS "UbiTrack_CUDA ${UbiTrack_LIBS}")
    set(_UbiTrack_LIBS "")
    foreach(_lib ${UbiTrack_LIBS})
      string(REPLACE "${UbiTrack_CONFIG_PATH}/gpu/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}" "${UbiTrack_CONFIG_PATH}/${UbiTrack_ARCH}/${UbiTrack_RUNTIME}" _lib2 "${_lib}")
      if(NOT EXISTS "${_lib}" AND EXISTS "${_lib2}")
        list(APPEND _UbiTrack_LIBS "${_lib2}")
      else()
        list(APPEND _UbiTrack_LIBS "${_lib}")
      endif()
    endforeach()
    set(UbiTrack_LIBS ${_UbiTrack_LIBS})
  endif()
  set(UbiTrack_FOUND TRUE CACHE BOOL "" FORCE)
  set(UBITRACK_FOUND TRUE CACHE BOOL "" FORCE)

  if(NOT UbiTrack_FIND_QUIETLY)
    message(STATUS "Found UbiTrack ${UbiTrack_VERSION} in ${UbiTrack_LIB_PATH}")
    if(NOT UbiTrack_LIB_PATH MATCHES "/staticlib")
      get_filename_component(_UbiTrack_LIB_PATH "${UbiTrack_LIB_PATH}/../bin" ABSOLUTE)
      file(TO_NATIVE_PATH "${_UbiTrack_LIB_PATH}" _UbiTrack_LIB_PATH)
      message(STATUS "You might need to add ${_UbiTrack_LIB_PATH} to your PATH to be able to run your applications.")
      if(UbiTrack_LIB_PATH MATCHES "/gpu/")
        string(REPLACE "\\gpu" "" _UbiTrack_LIB_PATH2 "${_UbiTrack_LIB_PATH}")
        message(STATUS "GPU support is enabled so you might also need ${_UbiTrack_LIB_PATH2} in your PATH (it must go after the ${_UbiTrack_LIB_PATH}).")
      endif()
    endif()
  endif()
else()
  if(NOT UbiTrack_FIND_QUIETLY)
    message(WARNING "Found UbiTrack 2.4.3 Windows Super Pack but it has not binaries compatible with your configuration.
    You should manually point CMake variable UbiTrack_DIR to your build of UbiTrack library.")
  endif()
  set(UbiTrack_FOUND FALSE CACHE BOOL "" FORCE)
  set(UBITRACK_FOUND FALSE CACHE BOOL "" FORCE)
endif()

