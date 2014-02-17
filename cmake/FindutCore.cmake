# - Find UTCore
# Find the native UTCore includes and library
#
# UTCORE_FOUND - True if UTCore found.
# UTCORE_INCLUDE_DIR - where to find utCore.h, etc.
# UTCORE_LIBRARIES - List of libraries when using UTCore.
#

IF( UTCORE_INCLUDE_DIR )
    # Already in cache, be silent
    SET( UTCore_FIND_QUIETLY TRUE )
ENDIF( UTCORE_INCLUDE_DIR )

FIND_PATH( UTCORE_INCLUDE_DIR "utCore.h"
           PATH_SUFFIXES "utCore/src" )

FIND_LIBRARY( UTCORE_LIBRARIES
              NAMES "utCore"
              PATH_SUFFIXES "" )

# handle the QUIETLY and REQUIRED arguments and set UTCORE_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE( "FindPackageHandleStandardArgs" )
FIND_PACKAGE_HANDLE_STANDARD_ARGS( "UTCore" DEFAULT_MSG UTCORE_INCLUDE_DIR UTCORE_LIBRARIES )

MARK_AS_ADVANCED( UTCORE_INCLUDE_DIR UTCORE_LIBRARIES )