# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries
# ----------------------------



# always used supplied tinyxml
set(TINYXML_LIBRARY CONAN_PKG::ubitrack_tinyxml)
set(TINYXML_LIBRARIES ${TINYXML_LIBRARY})
set(TINYXML_INCLUDE_DIR "${CONAN_INCLUDE_DIRS_UBITRACK_TINYXML}")
add_definitions(-DTIXML_USE_STL)
add_definitions(-DHAVE_TINYXML)
set(HAVE_TINYXML 1)

# always use supplied log4cpp
set(LOG4CPP_LIBRARY CONAN_PKG::ubitrack_log4cpp)
set(LOG4CPP_LIBRARIES ${LOG4CPP_LIBRARY})
set(LOG4CPP_INCLUDE_DIR "${CONAN_INCLUDE_DIRS_UBITRACK_LOG4CPP}")
add_definitions(-DHAVE_LOG4CPP)
set(HAVE_LOG4CPP 1)

# always use supplied boost bindings
set(BOOSTBINDINGS_INCLUDE_DIR "${CONAN_INCLUDE_DIRS_UBITRACK_BOOST_BINDINGS}")
IF(NOT WIN32)
  MESSAGE(STATUS "set boost::ublas alignment to 16")
  add_definitions("-DBOOST_UBLAS_BOUNDED_ARRAY_ALIGN=__attribute__ ((aligned (16)))")
ENDIF(NOT WIN32)
add_definitions(-DBOOST_SPIRIT_USE_OLD_NAMESPACE)
set(HAVE_BOOSTBINDINGS 1)


# Find Boost library. Required to compile.
set(BOOST_ROOT_DIR "${CONAN_BOOST_ROOT}")
SET(HAVE_BOOST 0)

if(ENABLE_BOOST_STATIC_LINKING)
	set(Boost_USE_STATIC_LIBS ON)
else()
	set(Boost_USE_STATIC_LIBS OFF)
endif()

set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package( Boost 1.59 COMPONENTS thread date_time system filesystem regex chrono locale serialization program_options REQUIRED)
if(Boost_FOUND)
  add_definitions("-DBOOST_ALL_NO_LIB")
  add_definitions("-DBOOST_FILESYSTEM_VERSION=3")
  add_definitions(-DHAVE_BOOST)
  SET(HAVE_BOOST 1)

  link_directories(${CONAN_LIB_DIRS_BOOST})
  message (STATUS "  Boost_LIBRARIES: ${Boost_LIBRARIES}")
endif(Boost_FOUND)

set(CLAPACK_DIR "${CONAN_CLAPACK_ROOT}")

SET(HAVE_LAPACK 0)
FIND_PACKAGE(CLAPACK)
IF(CLAPACK_FOUND)
  SET(LAPACK_FOUND ${CLAPACK_FOUND})
  add_definitions(-DHAVE_CLAPACK)
  SET(LAPACK_LIBRARIES ${CLAPACK_LIBRARIES})
ENDIF(CLAPACK_FOUND)
IF(LAPACK_FOUND)
  add_definitions(-DHAVE_LAPACK)
  SET(HAVE_LAPACK 1)
ENDIF(LAPACK_FOUND)

#OpenCV 
set(OPENCV_ROOT_DIR "${CONAN_OPENCV_ROOT}")

SET(OpenCV_CUDA OFF)
SET(HAVE_OPENCV 0)
FIND_PACKAGE(OpenCV COMPONENTS calib3d core features2d flann highgui imgcodecs imgproc ml objdetect video videoio)
IF(OPENCV_FOUND)
  MESSAGE(STATUS "Found: opencv, includes: ${OPENCV_INCLUDE_DIR}, libraries: ${OPENCV_LIBRARIES}")
  add_definitions(-DHAVE_OPENCV)
  SET(HAVE_OPENCV 1)
ENDIF(OPENCV_FOUND)

#MSGPACK
set(MSGPACK_ROOT_DIR "${CONAN_MSGPACK_ROOT}")

SET(HAVE_MSGPACK 0)
find_package(MSGPACK)
IF(MSGPACK_FOUND)
    add_definitions(-DHAVE_MSGPACK)
    SET(HAVE_MSGPACK 1)
ENDIF(MSGPACK_FOUND)



# Java
SET(_JAVA_HOME "${CONAN_JAVA_INSTALLER_ROOT}")
SET(HAVE_JAVA 0)
find_package(JNI)
IF(JNI_FOUND)
  add_definitions(-DHAVE_JAVA)
  SET(HAVE_JAVA 1)
  MESSAGE(STATUS "Found JAVA: ${JNI_INCLUDE_DIRS} - ${JNI_LIBRARIES}")
ENDIF(JNI_FOUND)


#SWIG
set(SWIG_ROOT_DIR "${CONAN_SWIG_ROOT}")
SET(HAVE_SWIG 0)
find_package(SWIG)
IF(SWIG_FOUND)
  add_definitions(-DHAVE_SWIG)
  SET(HAVE_SWIG 1)
  INCLUDE(${SWIG_USE_FILE})
ENDIF(SWIG_FOUND)


