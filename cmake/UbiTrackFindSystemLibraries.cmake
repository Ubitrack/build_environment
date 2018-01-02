# pthreads
SET(PTHREAD_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/pthread")
IF(UNIX)
  find_package(PTHREAD)
  IF(PTHREAD_FOUND)
    add_definitions(-DHAVE_PTHREAD)
    SET(HAVE_PTHREAD 1)
  ENDIF(PTHREAD_FOUND)
ENDIF(UNIX)

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
