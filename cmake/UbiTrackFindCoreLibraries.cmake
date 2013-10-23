# ----------------------------------------------------------------------------
#  Detect 3rd-party libraries
# ----------------------------

IF(X86_64)
	getenv_path(UBITRACKLIB_EXTERNAL64)
	IF(ENV_UBITRACKLIB_EXTERNAL64)
		SET(EXTERNAL_LIBRARIES_DIR "${ENV_UBITRACKLIB_EXTERNAL64}")
	ENDIF(ENV_UBITRACKLIB_EXTERNAL64)
ELSE()
	getenv_path(UBITRACKLIB_EXTERNAL32)
	IF(ENV_UBITRACKLIB_EXTERNAL32)
		SET(EXTERNAL_LIBRARIES_DIR "${ENV_UBITRACKLIB_EXTERNAL32}")
	ENDIF(ENV_UBITRACKLIB_EXTERNAL32)
ENDIF(X86_64)




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
IF(CMAKE_COMPILER_IS_GNUCXX)
  add_definitions("-DBOOST_UBLAS_BOUNDED_ARRAY_ALIGN=__attribute__ ((aligned (16)))")
ENDIF(CMAKE_COMPILER_IS_GNUCXX)
add_definitions(-DBOOST_SPIRIT_USE_OLD_NAMESPACE)
set(HAVE_BOOSTBINDINGS 1)


# Find Boost library. Required to compile.
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(BOOST_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/boost")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_BOOST 0)
if(MSVC)
  # force dynamic linking of boost libs on windows ..
  add_definitions(-DBOOST_ALL_DYN_LINK)
endif(MSVC)
set(Boost_USE_STATIC_LIBS   OFF)
set(Boost_USE_MULTITHREADED ON)
set(Boost_USE_STATIC_RUNTIME OFF)
find_package( Boost 1.49 COMPONENTS thread date_time system filesystem regex chrono locale serialization program_options python REQUIRED)
if(Boost_FOUND)
  add_definitions("-DBOOST_FILESYSTEM_VERSION=3")
  add_definitions(-DHAVE_BOOST)
  SET(HAVE_BOOST 1)

  link_directories(${Boost_LIBRARY_DIRS})
endif(Boost_FOUND)

# get python
find_package(PythonLibs REQUIRED)
IF(PYTHONLIBS_FOUND)
  link_directories(${PYTHON_LIBRARIES})
  add_definitions(-DHAVE_PYTHON)
  SET(HAVE_PYTHON 1)
ENDIF(PYTHONLIBS_FOUND)

# Find Lapack library. Required to compile.
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(LAPACK_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/lapack")
ENDIF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)

SET(HAVE_LAPACK 0)
IF(WIN32)
	FIND_PACKAGE(LAPACK)
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

SET(HAVE_OPENCV 0)
FIND_PACKAGE(OpenCV)
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

#FreeGlut
IF(WIN32 AND DEFINED EXTERNAL_LIBRARIES_DIR)
	set(FREEGLUT_ROOT_DIR "${EXTERNAL_LIBRARIES_DIR}/glut")
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

# pthreads
IF(UNIX)
	find_package(PTHREAD)
	IF(PTHREAD_FOUND)
	  add_definitions(-DHAVE_PTHREAD)
	  SET(HAVE_PTHREAD 1)
	ENDIF(PTHREAD_FOUND)
ENDIF(UNIX)
