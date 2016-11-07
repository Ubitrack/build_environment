# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries
# ----------------------------

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

MESSAGE(STATUS "EXTERNAL_LIBRARIES_DIR: ${EXTERNAL_LIBRARIES_DIR}")

if(WIN32)
  MESSAGE(STATUS "Setting minimum Windows version to Vista WINVER=0x0600")
  add_definitions(-DWINVER=0x0600)
endif(WIN32)

# pthreads
SET(PTHREAD_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/pthread")
IF(UNIX)
  find_package(PTHREAD)
  IF(PTHREAD_FOUND)
    add_definitions(-DHAVE_PTHREAD)
    SET(HAVE_PTHREAD 1)
  ENDIF(PTHREAD_FOUND)
ENDIF(UNIX)


# always used supplied tinyxml
set(TINYXML_LIBRARY tinyxml)
set(TINYXML_LIBRARIES ${TINYXML_LIBRARY})
add_subdirectory("${CMAKE_SOURCE_DIR}/modules/utcore/3rd/tinyxml")
set(TINYXML_INCLUDE_DIR "${${TINYXML_LIBRARY}_SOURCE_DIR}" "${${TINYXML_LIBRARY}_BINARY_DIR}")
add_definitions(-DTIXML_USE_STL)
add_definitions(-DHAVE_TINYXML)
set(HAVE_TINYXML 1)

# always use supplied log4cpp
set(LOG4CPP_LIBRARY log4cpp)
set(LOG4CPP_LIBRARIES ${LOG4CPP_LIBRARY})
add_subdirectory("${CMAKE_SOURCE_DIR}/modules/utcore/3rd/log4cpp")
set(LOG4CPP_INCLUDE_DIR "${${LOG4CPP_LIBRARY}_SOURCE_DIR}/include" "${${LOG4CPP_LIBRARY}_BINARY_DIR}")
add_definitions(-DHAVE_LOG4CPP)
set(HAVE_LOG4CPP 1)

# always use supplied boost bindings
set(BOOSTBINDINGS_INCLUDE_DIR "${CMAKE_SOURCE_DIR}/modules/utcore/3rd/boost-bindings")
add_subdirectory("${CMAKE_SOURCE_DIR}/modules/utcore/3rd/boost-bindings")
IF(NOT WIN32)
  MESSAGE(STATUS "set boost::ublas alignment to 16")
  add_definitions("-DBOOST_UBLAS_BOUNDED_ARRAY_ALIGN=__attribute__ ((aligned (16)))")
ENDIF(NOT WIN32)
add_definitions(-DBOOST_SPIRIT_USE_OLD_NAMESPACE)
set(HAVE_BOOSTBINDINGS 1)


# Find Boost library. Required to compile.
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(BOOST_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/boost")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_BOOST 0)


if(ENABLE_BOOST_STATIC_LINKING)
	set(Boost_USE_STATIC_LIBS ON)
else()
	set(Boost_USE_STATIC_LIBS OFF)
endif()
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package( Boost 1.49 COMPONENTS thread date_time system filesystem regex chrono locale serialization program_options REQUIRED)
if(Boost_FOUND)
  add_definitions("-DBOOST_ALL_NO_LIB")
  add_definitions("-DBOOST_FILESYSTEM_VERSION=3")
  add_definitions(-DHAVE_BOOST)
  SET(HAVE_BOOST 1)

  link_directories(${Boost_LIBRARY_DIRS})
  message (STATUS "  Boost_LIBRARIES: ${Boost_LIBRARIES}")

endif(Boost_FOUND)

# Find Lapack library. Required to compile.
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(LAPACK_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/lapack")
  set(CLAPACK_DIR "${EXTERNAL_LIBRARIES_DIR}/clapack")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_LAPACK 0)
IF(WIN32)
	FIND_PACKAGE(CLAPACK)
  IF(CLAPACK_FOUND)
    SET(LAPACK_FOUND ${CLAPACK_FOUND})
    add_definitions(-DHAVE_CLAPACK)
    include_directories(${CLAPACK_INCLUDE_DIR})
    SET(LAPACK_LIBRARIES ${CLAPACK_LIBRARIES})
  ENDIF(CLAPACK_FOUND)

	IF(NOT LAPACK_FOUND AND DEFINED EXTERNAL_LIBRARIES_DIR)
		SET(LAPACK_LIB_DIR "${EXTERNAL_LIBRARIES_DIR}/lapack/lib")
		# for now just manually define the libraries ..
		SET(LAPACK_LIBRARIES "${LAPACK_LIB_DIR}/atlas.lib" 
							 "${LAPACK_LIB_DIR}/cblas.lib" 
							 "${LAPACK_LIB_DIR}/f77blas.lib"
							 "${LAPACK_LIB_DIR}/g2c.lib"
							 "${LAPACK_LIB_DIR}/gcc.lib"
							 "${LAPACK_LIB_DIR}/lapack.lib"
							 )
		SET(LAPACK_FOUND 1)
	ENDIF(NOT LAPACK_FOUND AND DEFINED EXTERNAL_LIBRARIES_DIR)
ELSE()
	FIND_PACKAGE(LAPACK REQUIRED)
ENDIF(WIN32)
IF(LAPACK_FOUND)
  add_definitions(-DHAVE_LAPACK)
  SET(HAVE_LAPACK 1)
ENDIF(LAPACK_FOUND)

#OpenCV 
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(OPENCV_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/opencv")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(OpenCV_CUDA OFF)
SET(HAVE_OPENCV 0)
FIND_PACKAGE(OpenCV COMPONENTS calib3d core features2d flann highgui imgcodecs imgproc ml objdetect video videoio)
IF(OPENCV_FOUND)
  MESSAGE(STATUS "Found: opencv, includes: ${OPENCV_INCLUDE_DIR}, libraries: ${OPENCV_LIBRARIES}")
  add_definitions(-DHAVE_OPENCV)
  SET(HAVE_OPENCV 1)
ENDIF(OPENCV_FOUND)

# TBB
# setup defaults for windows binary distributions
if (WIN32)
    if (MSVC71)
        set (TBB_COMPILER "vc7.1")
    endif(MSVC71)
    if (MSVC80)
        set(TBB_COMPILER "vc8")
    endif(MSVC80)
    if (MSVC90)
        set(TBB_COMPILER "vc9")
    endif(MSVC90)
    if(MSVC10)
        set(TBB_COMPILER "vc10")
    endif(MSVC10)
    if(MSVC12)
        set(TBB_COMPILER "vc12")
    endif(MSVC12)
	IF(X86_64)
		set(TBB_ARCHITECTURE "intel64")
	ELSE()
		set(TBB_ARCHITECTURE "ia32")
	ENDIF(X86_64)
endif (WIN32)

IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(TBB_INSTALL_DIR "${EXTERNAL_LIBRARIES_DIR}/tbb")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_TBB 0)
find_package(TBB)
IF(TBB_FOUND)
  add_definitions(-DHAVE_TBB)
  SET(HAVE_TBB 1)
ENDIF(TBB_FOUND)

# OpenGL
SET(HAVE_OPENGL 0)
find_package(OpenGL)
IF(OpenGL_FOUND)
  add_definitions(-DHAVE_OPENGL)
  SET(HAVE_OPENGL 1)
  MESSAGE(STATUS "Found OpenGL: ${OpenGL_INCLUDE_DIR} - ${OpenGL_LIBRARIES}")
ENDIF(OpenGL_FOUND)

# OpenCL
SET(HAVE_OPENCL 0)
find_package(OpenCL)
IF(OpenCL_FOUND)
  add_definitions(-DHAVE_OPENCL)
  include_directories(${OpenCL_INCLUDE_DIR})
  SET(HAVE_OPENCL 1)
  MESSAGE(STATUS "Found OpenCL: ${OpenCL_INCLUDE_DIR} - ${OpenCL_LIBRARY}")
ENDIF(OpenCL_FOUND)

#FreeGlut
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(FREEGLUT_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/freeglut")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_FREEGLUT 0)
find_package(Freeglut)
IF(Freeglut_FOUND)
  add_definitions(-DHAVE_FREEGLUT)
  SET(HAVE_FREEGLUT 1)
  MESSAGE(STATUS "Found Freeglut: ${Freeglut_INCLUDE_DIR} - ${Freeglut_LIBRARIES}")
ENDIF(Freeglut_FOUND)

# Java
SET(HAVE_JAVA 0)
find_package(JNI)
IF(JNI_FOUND)
  add_definitions(-DHAVE_JAVA)
  SET(HAVE_JAVA 1)
  MESSAGE(STATUS "Found JAVA: ${JNI_INCLUDE_DIRS} - ${JNI_LIBRARIES}")
ENDIF(JNI_FOUND)


#SWIG
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(SWIG_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/swig")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_SWIG 0)
find_package(SWIG)
IF(SWIG_FOUND)
  add_definitions(-DHAVE_SWIG)
  SET(HAVE_SWIG 1)
  INCLUDE(${SWIG_USE_FILE})
ENDIF(SWIG_FOUND)


# Tracing Providers for various platforms
IF(ENABLE_TRACING_DTRACE)
    MESSAGE( STATUS "Enabled DTrace.")
    INCLUDE(dtrace)
    add_definitions("-DHAVE_DTRACE")
    add_definitions("-DENABLE_EVENT_TRACING")
    include_directories(${CMAKE_BINARY_DIR})
ENDIF(ENABLE_TRACING_DTRACE)

IF(ENABLE_TRACING_ETW)
    MESSAGE( STATUS "Enabled Event Tracing for Windows.")
    INCLUDE(etw)
    add_definitions("-DHAVE_ETW")
    add_definitions("-DENABLE_EVENT_TRACING")
    include_directories(${CMAKE_BINARY_DIR})
ENDIF(ENABLE_TRACING_ETW)


# example provided here:
# https://github.com/lttng/lttng-ust/tree/master/doc/examples/cmake-multiple-shared-libraries
IF(ENABLE_TRACING_LTTNGUST)
    MESSAGE( STATUS "Enabled LTTNG-UST.")
    include (FindLTTngUST REQUIRED)
    MESSAGE(STATUS "Found LTTNG-UST tools and headers")
    add_definitions("-DHAVE_LTTNGUST")
    add_definitions("-DENABLE_EVENT_TRACING")
ENDIF(ENABLE_TRACING_LTTNGUST)

