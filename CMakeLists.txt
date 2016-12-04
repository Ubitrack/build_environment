# Adapted from OpenCV CMake Infrastructure, git repository 05/2013
# by Ulrich Eck
set(CMAKE_ALLOW_LOOSE_LOOP_CONSTRUCTS true)

# --------------------------------------------------------------
# Indicate CMake 2.7 and above that we don't want to mix relative
#  and absolute paths in linker lib lists.
# Run "cmake --help-policy CMP0003" for more information.
# --------------------------------------------------------------
if(COMMAND cmake_policy)
  if(POLICY CMP0003)
    cmake_policy(SET CMP0003 NEW)
  endif()
  if(POLICY CMP0042)
    cmake_policy(SET CMP0042 NEW)
  endif()
  if(POLICY CMP0053)
  	cmake_policy(SET CMP0053 NEW)
  endif()
  if(POLICY CMP0054)
    cmake_policy(SET CMP0054 NEW)
  endif()
endif()

# Following block can broke build in case of cross-compilng
# but CMAKE_CROSSCOMPILING variable will be set only on project(UbiTrack) command
# so we will try to detect crosscompiling by presense of CMAKE_TOOLCHAIN_FILE
if(NOT CMAKE_TOOLCHAIN_FILE)
  # it _must_ go before project(UbiTrack) in order to work
  if(WIN32)
    set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory")
  else()
    set(CMAKE_INSTALL_PREFIX "/usr/local" CACHE PATH "Installation Directory")
  endif()

  if(MSVC)
    set(CMAKE_USE_RELATIVE_PATHS ON CACHE INTERNAL "" FORCE)
  endif()
else(NOT CMAKE_TOOLCHAIN_FILE)
  #Android: set output folder to ${CMAKE_BINARY_DIR}
  set( LIBRARY_OUTPUT_PATH_ROOT ${CMAKE_BINARY_DIR} CACHE PATH "root for library output, set this to change where android libs are compiled to" )
  # any crosscompiling
  set(CMAKE_INSTALL_PREFIX "${CMAKE_BINARY_DIR}/install" CACHE PATH "Installation Directory")
endif(NOT CMAKE_TOOLCHAIN_FILE)

# --------------------------------------------------------------
# Top level UbiTrack project
# --------------------------------------------------------------
if(CMAKE_GENERATOR MATCHES Xcode AND XCODE_VERSION VERSION_GREATER 4.3)
  cmake_minimum_required(VERSION 3.4.0)
elseif(IOS)
  cmake_minimum_required(VERSION 3.4.0)
else()
  cmake_minimum_required(VERSION 3.4.0)
endif()

# must go before the project command
set(CMAKE_CONFIGURATION_TYPES "Debug;Release;RelWithDebInfo" CACHE STRING "Configs" FORCE)
if(DEFINED CMAKE_BUILD_TYPE AND CMAKE_VERSION VERSION_GREATER "2.8")
  set_property( CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS ${CMAKE_CONFIGURATION_TYPES} )
endif()

PROJECT(UbiTack CXX C)

SET(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake" )

include(cmake/UbiTrackUtils.cmake)
if(WIN32)
	include(cmake/UbiTrackDetermineCSharpCompiler.cmake)
	include(cmake/UbiTrackCSharpHelpers.cmake)
endif(WIN32)

# ----------------------------------------------------------------------------
# Break in case of popular CMake configuration mistakes
# ----------------------------------------------------------------------------
if(NOT CMAKE_SIZEOF_VOID_P GREATER 0)
  message(FATAL_ERROR "CMake fails to deterimine the bitness of target platform.
  Please check your CMake and compiler installation. If you are crosscompiling then ensure that your CMake toolchain file correctly sets the compiler details.")
endif()


# ----------------------------------------------------------------------------
# Detect compiler and target platform architecture
# ----------------------------------------------------------------------------
include(cmake/UbiTrackDetectCXXCompiler.cmake)

# Add these standard paths to the search paths for FIND_LIBRARY
# to find libraries from these locations first
if(UNIX AND NOT ANDROID)
  if(X86_64 OR CMAKE_SIZEOF_VOID_P EQUAL 8)
    if(EXISTS /lib64)
      list(APPEND CMAKE_LIBRARY_PATH /lib64)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /lib)
    endif()
    if(EXISTS /usr/lib64)
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib64)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib)
    endif()
  elseif(X86 OR CMAKE_SIZEOF_VOID_P EQUAL 4)
    if(EXISTS /lib32)
      list(APPEND CMAKE_LIBRARY_PATH /lib32)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /lib)
    endif()
    if(EXISTS /usr/lib32)
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib32)
    else()
      list(APPEND CMAKE_LIBRARY_PATH /usr/lib)
    endif()
  endif()
endif()

if(WIN32)
	  set(UBITRACK_COMPILE_FLAGS "/EHsc /c /W3 /GR /wd4355 /wd4996 /wd4251 /wd4275 /wd4819 /wd4290")
	  set(UBITRACK_LINK_FLAGS "/SUBSYSTEM:CONSOLE")
	  #set(UBITRACK_DEFINES "WIN32" "_MBCS" "_WIN32_WINNT=0x501")	
    set(UBITRACK_DEFINES "WIN32" "_MBCS")  
    set(UBITRACK_LINK_FLAGS_DEBUG "/NODEFAULTLIB:libc.lib /NODEFAULTLIB:libcmt.lib /NODEFAULTLIB:msvcrt.lib /NODEFAULTLIB:libcd.lib /NODEFAULTLIB:libcmtd.lib")
endif(WIN32)

# Option to use Macports ??
if(APPLE)
  list(APPEND CMAKE_LIBRARY_PATH /opt/local/lib)	

  set(CMAKE_MACOSX_RPATH ON)

  # use, i.e. don't skip the full RPATH for the build tree
  SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

  # when building, don't use the install RPATH already
  # (but later on when installing)
  SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE)

  SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

  # add the automatically determined parts of the RPATH
  # which point to directories outside the build tree to the install RPATH
  SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


  # the RPATH to be used when installing, but only if it's not a system directory
  LIST(FIND CMAKE_PLATFORM_IMPLICIT_LINK_DIRECTORIES "${CMAKE_INSTALL_PREFIX}/lib" isSystemDir)
  IF("${isSystemDir}" STREQUAL "-1")
     SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
  ENDIF("${isSystemDir}" STREQUAL "-1")


endif(APPLE)

if(MSVC_IDE OR CMAKE_GENERATOR MATCHES Xcode)
  set(ENABLE_SOLUTION_FOLDERS0 ON)
else()
  set(ENABLE_SOLUTION_FOLDERS0 OFF)
endif()

## The Configuration names should have a unique PREFIX .. e.g. UT or UBITRACK_OPTION_ .. or whatever ..
## This should also be done for the BUILD_XXX options

# Build Options go here
UT_OPTION(GENERATE_METADATA    "Generate Metadata for Modules and Components"    OFF)
UT_OPTION(BUILD_TESTS          "Build regression tests"                          ON)

UT_OPTION(ENABLE_PRECOMPILED_HEADERS "Use precompiled headers"                                  ON )
UT_OPTION(ENABLE_SOLUTION_FOLDERS    "Solution folder in Visual Studio or in other IDEs"        ${ENABLE_SOLUTION_FOLDERS0} IF (CMAKE_VERSION VERSION_GREATER "2.8.0") )
UT_OPTION(COMPILE_WITH_CXX11   "Compile UbiTrack using C++11 (GCC)"    ON)
UT_OPTION(ENABLE_BOOST_STATIC_LINKING   "Enable static linking for boost libraries."    OFF)
UT_OPTION(ENABLE_EXPAND_MULTICOMPONENTS "Expand Components into single libraries (does not yet work properly!!!)" ON)

IF(APPLE)
  UT_OPTION(ENABLE_TRACING_DTRACE "Enable DTrace tracing of eventqueue activity?" OFF)
ENDIF(APPLE)
IF(WIN32)
  UT_OPTION(ENABLE_TRACING_ETW "Enable ETW Tracing of eventqueue activity?" OFF)
ENDIF(WIN32)
IF(CMAKE_SYSTEM_NAME MATCHES "Linux")
  UT_OPTION(ENABLE_TRACING_LTTNGUST "Enable LTTNG-UST Tracing of eventqueue activity?" OFF)
ENDIF(CMAKE_SYSTEM_NAME MATCHES "Linux")

set(UT_MAXIMUM_EVENTQUEUE_LENGTH "7" CACHE FILEPATH "Maximum EventQueue length")
add_definitions("-DMAXIMUM_EVENTQUEUE_LENGTH=${UT_MAXIMUM_EVENTQUEUE_LENGTH}")

set(UT_MAXIMUM_EVENTQUEUES "4" CACHE FILEPATH "Maximum number of EventQueues")
add_definitions("-DUT_MAXIMUM_EVENTQUEUES=${UT_MAXIMUM_EVENTQUEUES}")

set(UT_EXTERNAL_LIBRARIES_DIR "" CACHE FILEPATH "Manually set EXTERNAL_LIBRARIES_DIR")


# Activate C++11 mode if available
IF(COMPILE_WITH_CXX11)
  add_definitions("-DCOMPILER_USE_CXX11")
  SET(ENABLE_CXX11 "-std=c++11")
  if (${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
      execute_process(
          COMMAND ${CMAKE_CXX_COMPILER} -dumpversion OUTPUT_VARIABLE GCC_VERSION)
      if (GCC_VERSION VERSION_GREATER 4.7 OR GCC_VERSION VERSION_EQUAL 4.7)
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ENABLE_CXX11}")
      endif ()
  elseif (${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
      set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${ENABLE_CXX11} -stdlib=libc++")
  endif ()
ENDIF(COMPILE_WITH_CXX11)

# Set Ubitrack Version (can we get it from headers ?)
SET(UBITRACK_VERSION_MAJOR 1)
SET(UBITRACK_VERSION_MINOR 3)
SET(UBITRACK_VERSION_PATCH 0)

SET(UBITRACK_SOVERSION "${UBITRACK_VERSION_MAJOR}.${UBITRACK_VERSION_MINOR}")
SET(UBITRACK_LIBVERSION "${UBITRACK_VERSION_MAJOR}.${UBITRACK_VERSION_MINOR}.${UBITRACK_VERSION_PATCH}")

# Should be an option ..
OPTION(BUILD_SHARED_LIBS "Build Shared Libraries" ON)

# ----------------------------------------------------------------------------
#  Build & install layouts
# ----------------------------------------------------------------------------

# Save libs and executables in the same place
set(EXECUTABLE_OUTPUT_PATH "${CMAKE_BINARY_DIR}/bin" CACHE PATH "Output directory for applications" )

if(ANDROID OR WIN32)
  set(UBITRACK_DOC_INSTALL_PATH doc)
else()
  set(UBITRACK_DOC_INSTALL_PATH share/UbiTrack/doc)
endif()

if(ANDROID)
  set(LIBRARY_OUTPUT_PATH         "${CMAKE_BINARY_DIR}/lib/${ANDROID_NDK_ABI_NAME}")
  set(3P_LIBRARY_OUTPUT_PATH      "${CMAKE_BINARY_DIR}/3rdparty/lib/${ANDROID_NDK_ABI_NAME}")
  set(UBITRACK_LIB_INSTALL_PATH     sdk/native/libs/${ANDROID_NDK_ABI_NAME})
  set(UBITRACK_3P_LIB_INSTALL_PATH  sdk/native/3rdparty/libs/${ANDROID_NDK_ABI_NAME})
  set(UBITRACK_CONFIG_INSTALL_PATH  sdk/native/jni)
  set(UBITRACK_INCLUDE_INSTALL_PATH sdk/native/jni/include)
else()
  set(LIBRARY_OUTPUT_PATH         "${CMAKE_BINARY_DIR}/lib")
  set(3P_LIBRARY_OUTPUT_PATH      "${CMAKE_BINARY_DIR}/3rdparty/lib${LIB_SUFFIX}")
  set(UBITRACK_LIB_INSTALL_PATH     lib${LIB_SUFFIX})
  set(UBITRACK_3P_LIB_INSTALL_PATH  share/UbiTrack/3rdparty/${UBITRACK_LIB_INSTALL_PATH})
  set(UBITRACK_INCLUDE_INSTALL_PATH include)

  math(EXPR SIZEOF_VOID_P_BITS "8 * ${CMAKE_SIZEOF_VOID_P}")
  if(LIB_SUFFIX AND NOT SIZEOF_VOID_P_BITS EQUAL LIB_SUFFIX)
    set(UBITRACK_CONFIG_INSTALL_PATH lib${LIB_SUFFIX}/cmake/ubitrack)
  else()
    set(UBITRACK_CONFIG_INSTALL_PATH share/UbiTrack)
  endif()
endif()

set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${UBITRACK_LIB_INSTALL_PATH}")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)


set(UBITRACK_COMPONENT_INSTALL_DIRECTORY "ubitrack")
IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
    set(UBITRACK_COMPONENT_INSTALL_DIRECTORY "${UBITRACK_COMPONENT_INSTALL_DIRECTORY}d")
ENDIF(CMAKE_BUILD_TYPE MATCHES DEBUG)
set(UBITRACK_COMPONENT_INSTALL_PATH "${UBITRACK_LIB_INSTALL_PATH}/${UBITRACK_COMPONENT_INSTALL_DIRECTORY}")
set(UBITRACK_COMPONENT_BIN_INSTALL_PATH "bin/${UBITRACK_COMPONENT_INSTALL_DIRECTORY}")

set(UBITRACK_MODULE_TYPE SHARED)

set(UBITRACK_DOC_INSTALL_DIRECTORY "share/UbiTrack/doc")
set(UBITRACK_UTQLPATTERN_INSTALL_DIRECTORY "share/UbiTrack/utql")
set(UBITRACK_METADATA_INSTALL_DIRECTORY "share/UbiTrack/metadata")

if(WIN32)
  # Postfix of DLLs:
  set(UBITRACK_DLLVERSION "${UBITRACK_VERSION_MAJOR}${UBITRACK_VERSION_MINOR}${UBITRACK_VERSION_PATCH}")
  set(UBITRACK_DEBUG_POSTFIX d)
else()
  # Postfix of so's:
  set(UBITRACK_DLLVERSION "")
  set(UBITRACK_DEBUG_POSTFIX "")
endif()

if(DEFINED CMAKE_DEBUG_POSTFIX)
  set(UBITRACK_DEBUG_POSTFIX "${CMAKE_DEBUG_POSTFIX}")
endif()


# external libraries lookup directory
IF (UT_EXTERNAL_LIBRARIES_DIR STREQUAL "")
  IF(X86_64)
    MESSAGE(STATUS "Building 64-Bit Version")
    getenv_path(UBITRACKLIB_EXTERNAL64)
    IF(ENV_UBITRACKLIB_EXTERNAL64)
      SET(EXTERNAL_LIBRARIES_DIR "${ENV_UBITRACKLIB_EXTERNAL64}")
    ENDIF(ENV_UBITRACKLIB_EXTERNAL64)
  ELSE(X86_64)
    MESSAGE(STATUS "Building 32-Bit Version")
    getenv_path(UBITRACKLIB_EXTERNAL32)
    IF(ENV_UBITRACKLIB_EXTERNAL32)
      SET(EXTERNAL_LIBRARIES_DIR "${ENV_UBITRACKLIB_EXTERNAL32}")
    ENDIF(ENV_UBITRACKLIB_EXTERNAL32)
  ENDIF(X86_64)
  MESSAGE(STATUS "Automatically determined EXTERNAL_LIBRARIES_DIR: ${EXTERNAL_LIBRARIES_DIR}")
ELSE (UT_EXTERNAL_LIBRARIES_DIR STREQUAL "")
  SET(EXTERNAL_LIBRARIES_DIR ${UT_EXTERNAL_LIBRARIES_DIR})
  MESSAGE(STATUS "Use manually set EXTERNAL_LIBRARIES_DIR: ${EXTERNAL_LIBRARIES_DIR}")
ENDIF (UT_EXTERNAL_LIBRARIES_DIR STREQUAL "")

# Include Module Functions
include(cmake/UbiTrackModule.cmake)

# Include Component Functions
include(cmake/UbiTrackComponent.cmake)

# Include App Functions
include(cmake/UbiTrackApp.cmake)

# --- Java Support ---
include(cmake/UbiTrackDetectApacheAnt.cmake)
if(ANDROID)
  include(cmake/UbiTrackDetectAndroidSDK.cmake)

  if(NOT ANDROID_TOOLS_Pkg_Revision GREATER 13)
    message(WARNING "UbiTrack requires Android SDK tools revision 14 or newer. Otherwise tests and samples will no be compiled.")
  endif()
elseif(ANT_EXECUTABLE)
  find_package(JNI)
endif()

if(ANDROID AND ANDROID_EXECUTABLE AND ANT_EXECUTABLE AND (ANT_VERSION VERSION_GREATER 1.7) AND (ANDROID_TOOLS_Pkg_Revision GREATER 13))
  SET(CAN_BUILD_ANDROID_PROJECTS TRUE)
else()
  SET(CAN_BUILD_ANDROID_PROJECTS FALSE)
endif()

# set compiler for xcode builds on osx
if(APPLE)
	set(CMAKE_XCODE_ATTRIBUTE_GCC_VERSION "com.apple.compilers.llvmgcc42")
endif(APPLE)


## Check for Windows ##
if( WIN32 ) # true if windows (32 and 64 bit)
    MESSAGE(STATUS "Building for ${CMAKE_SYSTEM_NAME} ${CMAKE_SYSTEM_VERSION}")
    ## Check for Version ##
    if( ${CMAKE_SYSTEM_VERSION} EQUAL 6.1 ) # Windows 7
      MESSAGE(STATUS "Setting minimum Windows version to Win7 WINVER=0x0601")
      add_definitions(-DWINVER=0x0601)
    elseif( ${CMAKE_SYSTEM_VERSION} EQUAL 6.2 ) # Windows 8
      MESSAGE(STATUS "Setting minimum Windows version to Win8 WINVER=0x0602")
      add_definitions(-DWINVER=0x0602)
    elseif( ${CMAKE_SYSTEM_VERSION} EQUAL 6.3 ) # Windows 8.1
      MESSAGE(STATUS "Setting minimum Windows version to Win8.1 WINVER=0x0603")
      add_definitions(-DWINVER=0x0602)
    elseif( ${CMAKE_SYSTEM_VERSION} EQUAL 10.0 ) # Windows 10
      MESSAGE(STATUS "Setting minimum Windows version to Win8.1 WINVER=0x0603")
      add_definitions(-DWINVER=0x0602)
    else() # Some other Windows
      MESSAGE(STATUS "Setting minimum Windows version to Vista WINVER=0x0600")
      add_definitions(-DWINVER=0x0600)
    endif()

endif()


# add 3rdparty libraries
include(cmake/UbiTrackFindCoreLibraries.cmake)

# all core includes
set(UBITRACK_CORE_DEPS_INCLUDE_DIR 
		${TINYXML_INCLUDE_DIR} 
		${LOG4CPP_INCLUDE_DIR} 
		${BOOSTBINDINGS_INCLUDE_DIR} 
		${LAPACK_INCLUDE_DIR} 
		${Boost_INCLUDE_DIR} 
		)

# Extra UbiTrack targets: uninstall, package_source, perf, etc.
include(cmake/UbiTrackExtraTargets.cmake)


# UbiTrack modules
add_subdirectory(modules)

# ----------------------------------------------------------------------------
# Finalization: generate configuration-based files
# ----------------------------------------------------------------------------
ut_track_build_dependencies()

# Generate platform-dependent and configuration-dependent headers
#include(cmake/UbiTrackGenHeaders.cmake)

# Generate ubitrack.pc for pkg-config command
#include(cmake/UbiTrackGenPkgconfig.cmake)

# Generate UbiTrack.mk for ndk-build (Android build tool)
#include(cmake/UbiTrackGenAndroidMK.cmake)

# Generate UbiTrackonfig.cmake and UbiTrackConfig-version.cmake for cmake projects
#include(cmake/UbiTrackGenConfig.cmake)

#Status
foreach(m ${UBITRACK_MODULES_BUILD})
	MESSAGE(STATUS "Configured Module: ${m}")
endforeach()

foreach(m ${UBITRACK_COMPONENTS_BUILD})
	MESSAGE(STATUS "Configured Component: ${m}")
endforeach()

foreach(m ${UBITRACK_APPS_BUILD})
	MESSAGE(STATUS "Configured App: ${m}")
endforeach()

# ----------------------------------------------------------------------------
# CPack stuff
# ----------------------------------------------------------------------------

include(cmake/UbitrackPackaging.cmake)