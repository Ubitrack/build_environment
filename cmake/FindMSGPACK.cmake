# - Find msgpack
# Find the native Message Pack headers and libraries.
#
# MSGPACK_INCLUDE_DIRS - where to find msgpack.hpp, etc.
# MSGPACK_LIBRARIES - List of libraries when using MSGPACK.
# MSGPACK_FOUND - True if MSGPACK found.


# Look for the header file.
FIND_PATH(MSGPACK_INCLUDE_DIR NAMES msgpack.hpp
        PATHS ${MSGPACK_ROOT_DIR}/include
            /usr/local/include
            /usr/include)

# Look for the library.
FIND_LIBRARY(MSGPACK_LIBRARY NAMES msgpack msgpackc libmsgpack.a libmsgpackc.a
        PATHS ${MSGPACK_ROOT_DIR}/lib
            /usr/local/lib
            /usr/lib)

# handle the QUIETLY and REQUIRED arguments and set MSGPACK_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(MSGPACK DEFAULT_MSG MSGPACK_LIBRARY MSGPACK_INCLUDE_DIR)

# Copy the results to the output variables.
IF(MSGPACK_FOUND)
    MESSAGE(STATUS "Found MSGPACK")
    SET(MSGPACK_LIBRARIES ${MSGPACK_LIBRARY})
    SET(MSGPACK_INCLUDE_DIRS ${MSGPACK_INCLUDE_DIR})
ELSE(MSGPACK_FOUND)
    SET(MSGPACK_LIBRARIES)
    SET(MSGPACK_INCLUDE_DIRS)
ENDIF(MSGPACK_FOUND)

MARK_AS_ADVANCED(MSGPACK_INCLUDE_DIR MSGPACK_LIBRARY)