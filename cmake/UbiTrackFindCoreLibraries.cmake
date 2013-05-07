# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries
# ----------------------------------------------------------------------------
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
add_definitions("-DBOOST_UBLAS_BOUNDED_ARRAY_ALIGN=__attribute__ ((aligned (16)))")
add_definitions(-DBOOST_SPIRIT_USE_OLD_NAMESPACE)
set(HAVE_BOOSTBINDINGS 1)


# Find Boost library. Required to compile.
SET(HAVE_BOOST 0)
set(Boost_USE_STATIC_LIBS   OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package( Boost 1.49 COMPONENTS thread date_time system filesystem regex chrono locale serialization REQUIRED)
if(Boost_FOUND)
  add_definitions("-DBOOST_FILESYSTEM_VERSION=3")
  add_definitions(-DHAVE_BOOST)
  SET(HAVE_BOOST 1)
endif(Boost_FOUND)

# Find Lapack library. Required to compile.
SET(HAVE_LAPACK 0)
FIND_PACKAGE(LAPACK REQUIRED)
IF(LAPACK_FOUND)
  add_definitions(-DHAVE_LAPACK)
  SET(HAVE_LAPACK 1)
ENDIF(LAPACK_FOUND)

#OpenCV 
SET(HAVE_OPENCV 0)
FIND_PACKAGE(OpenCV)
IF(OpenCV_FOUND)
  MESSAGE(STATUS "Found: opencv, includes: ${OpenCV_INCLUDE_DIR}, libraries: ${OpenCV_LIBRARIES}")
  add_definitions(-DHAVE_OPENCV)
  SET(HAVE_OPENCV 1)
ENDIF(OpenCV_FOUND)

# If your TBB install directory is not found automatically, enter it here or use TBB_INSTALL_DIR env variable. (w/o trailing slash)
#set(TBB_INSTALL_DIR "/usr/local")
# Enter your architecture [ia32|em64t|itanium] here
#set(TBB_ARCHITECTURE "em64t")
# If your compiler is not detected automatically, enter it here. (e.g. vc9 or cc3.2.3_libc2.3.2_kernel2.4.21 or cc4.0.1_os10.4.9)
#set(TBB_COMPILER "...")
SET(HAVE_TBB 0)
find_package(TBB)
IF(TBB_FOUND)
  add_definitions(-DHAVE_TBB)
  SET(HAVE_TBB 1)
ENDIF(TBB_FOUND)


SET(HAVE_OPENGL 0)
find_package(OpenGL)
IF(OpenGL_FOUND)
  add_definitions(-DHAVE_OPENGL)
  SET(HAVE_OPENGL 1)
  MESSAGE(STATUS "Found OpenGL: ${OpenGL_INCLUDE_DIR} - ${OpenGL_LIBRARIES}")
ENDIF(OpenGL_FOUND)

SET(HAVE_FREEGLUT 0)
find_package(Freeglut)
IF(Freeglut_FOUND)
  add_definitions(-DHAVE_FREEGLUT)
  SET(HAVE_FREEGLUT 1)
  MESSAGE(STATUS "Found Freeglut: ${Freeglut_INCLUDE_DIR} - ${Freeglut_LIBRARIES}")
ENDIF(Freeglut_FOUND)
