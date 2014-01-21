# Adapted from OpenCV CMake Infrastructure, git repository 05/2013
# by Ulrich Eck

# Local variables (set for each app):
#
# name       - short name in lower case i.e. core
# the_app - full name in lower case i.e. utcore

# Global variables:
#
# UBITRACK_APP_${the_app}_LOCATION
# UBITRACK_APP_${the_app}_DESCRIPTION
# UBITRACK_APP_${the_app}_HEADERS
# UBITRACK_APP_${the_app}_SOURCES
# UBITRACK_APP_${the_app}_DEPS - final flattened set of app dependencies
# UBITRACK_APP_${the_app}_DEPS_EXT
# UBITRACK_APP_${the_app}_REQ_DEPS
# UBITRACK_APP_${the_app}_OPT_DEPS

# To control the setup of the app you could also set:
# the_description - text to be used as current app description
# UBITRACK_APP_TYPE - SINGLE|MULTI - set app type to single/multiple

# The verbose template for UbiTrack app:
#
#   ut_add_app(appname <dependencies>)
#   ut_glob_app_sources() or glob them manually and ut_set_app_sources(...)
#   ut_app_include_directories(<extra include directories>)
#   ut_create_app()
#

# clean apps info which needs to be recalculated
set(UBITRACK_APPS_BUILD          "" CACHE INTERNAL "List of UbiTrack apps included into the build")

# adds dependencies to UbiTrack app
# Usage:
#   add_app_dependencies(ubitrack_<name> [REQUIRED] [<list of dependencies>] [OPTIONAL <list of apps>])
# Notes:
# * <list of dependencies> - can include full names of apps or full pathes to shared/static libraries or cmake targets
macro(ut_add_app_dependencies full_appname)
  #we don't clean the dependencies here to allow this macro several times for every app
  foreach(d "REQUIRED" ${ARGN})
    if(d STREQUAL "REQUIRED")
      set(__depsvar UBITRACK_APP_${full_appname}_DEPS)
    else()
      list(APPEND ${__depsvar} "${d}")
    endif()
  endforeach()
  unset(__depsvar)

  ut_list_unique(UBITRACK_APP_${full_appname}_DEPS)

  set(UBITRACK_APP_${full_appname}_DEPS ${UBITRACK_APP_${full_appname}_DEPS} CACHE INTERNAL "Required dependencies of ${full_appname} app")
endmacro()

# declare new UbiTrack app in current folder
# Usage:
#   ut_add_app(<name> [DEPS] [<list of dependencies>])
# Example:
#   ut_add_app(utapps DEPS utcore utdataflow)
macro(ut_add_app name)
  #string(TOLOWER "${_name}" name)
  set(the_app ${name})

  # the first pass - collect apps info, the second pass - create targets
  if(UBITRACK_INITIAL_PASS)
    #guard agains redefinition
    if(";${UBITRACK_APPS_BUILD};" MATCHES ";${the_app};")
      message(FATAL_ERROR "Redefinition of the ${the_app} app.
  at:                    ${CMAKE_CURRENT_SOURCE_DIR}
  previously defined at: ${UBITRACK_APP_${the_app}_LOCATION}
")
    endif()

    if(NOT DEFINED the_description)
      set(the_description "The ${name} UbiTrack app")
    endif()

    if(NOT DEFINED BUILD_${the_app}_INIT)
      set(BUILD_${the_app}_INIT ON)
    endif()

    # create option to enable/disable this app
    option(BUILD_${the_app} "Include ${the_app} app into the UbiTrack build" ${BUILD_${the_app}_INIT})

    if(BUILD_${the_app})
      set(UBITRACK_APPS_BUILD ${UBITRACK_APPS_BUILD} "${the_app}" CACHE INTERNAL "List of UbiTrack apps included into the build")
    endif()

    # remember the app details
    set(UBITRACK_APP_${the_app}_DESCRIPTION "${the_description}" CACHE INTERNAL "Brief description of ${the_app} app")
    set(UBITRACK_APP_${the_app}_LOCATION    "${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "Location of ${the_app} app sources")
	
    # parse list of dependencies
    if("${ARGV1}" STREQUAL "DEPS")
      set(__ut_argn__ ${ARGN})
      list(REMOVE_AT __ut_argn__ 0)
      ut_add_app_dependencies(${the_app} ${__ut_argn__})
      unset(__ut_argn__)
    endif()

    # stop processing of current file
    return()
  else(UBITRACK_INITIAL_PASS)
    if(NOT BUILD_${the_app})
      return() # extra protection from redefinition
    endif()
    project(${the_app})
  endif(UBITRACK_INITIAL_PASS)
endmacro()

# setup include path for UbiTrack headers for specified app
# ut_module_include_directories(<extra include directories/extra include modules>)
macro(ut_app_include_directories)
  ut_include_directories( "${UBITRACK_APP_${the_app}_LOCATION}"
                          "${CMAKE_CURRENT_BINARY_DIR}" # for precompiled headers
                          )
  ut_include_modules(${UBITRACK_APP_${the_app}_DEPS} ${ARGN})
endmacro()

# sets header and source files for the current app
# NB: all files specified as headers will be installed
# Usage:
# ut_set_app_sources([HEADERS] <list of files> [SOURCES] <list of files>)
macro(ut_set_app_sources)
  set(UBITRACK_APP_${the_app}_HEADERS "")
  set(UBITRACK_APP_${the_app}_SOURCES "")

  foreach(f "HEADERS" ${ARGN})
	# ignore filenames, which contain *
	if(f MATCHES "^.*[*].*$")
		# ignore
    elseif(f STREQUAL "HEADERS" OR f STREQUAL "SOURCES")
      set(__filesvar "UBITRACK_APP_${the_app}_${f}")
    else()
      list(APPEND ${__filesvar} "${f}")
    endif()
  endforeach()

  # the hacky way to embeed any files into the UbiTrack without modification of its build system
  if(COMMAND ut_get_app_external_sources)
    ut_get_app_external_sources()
  endif()

  # use full paths for app to be independent from the app location
  ut_convert_to_full_paths(UBITRACK_APP_${the_app}_HEADERS)

  set(UBITRACK_APP_${the_app}_HEADERS ${UBITRACK_APP_${the_app}_HEADERS} CACHE INTERNAL "List of header files for ${the_app}")
  set(UBITRACK_APP_${the_app}_SOURCES ${UBITRACK_APP_${the_app}_SOURCES} CACHE INTERNAL "List of source files for ${the_app}")
endmacro()

# finds and sets headers and sources for the standard UbiTrack app
# Usage:
# ut_glob_app_sources(<extra sources&headers in the same format as used in ut_set_app_sources>)
macro(ut_glob_app_sources)
  set(UBITRACK_APP_${the_app}_GLOB_HEADERS "")
  set(UBITRACK_APP_${the_app}_GLOB_SOURCES "")

  foreach(f "HEADERS" ${ARGN})
	if(f STREQUAL "HEADERS" OR f STREQUAL "SOURCES")
      set(__filesvar "UBITRACK_APP_${the_app}_GLOB_${f}")
    else()
      list(APPEND ${__filesvar} "${f}")
    endif()
  endforeach()
	
	
  file(GLOB lib_srcs ${UBITRACK_APP_${the_app}_GLOB_SOURCES})
  file(GLOB lib_hdrs ${UBITRACK_APP_${the_app}_GLOB_HEADERS})
  ut_set_app_sources(HEADERS ${lib_hdrs}
                        SOURCES ${lib_srcs})

  source_group("Src" FILES ${lib_srcs})
  source_group("Include" FILES ${lib_hdrs})
endmacro()

# creates UbiTrack app in current folder
# creates new target, configures standard dependencies, compilers flags, install rules
# Usage:
#   ut_create_executable(<extra link dependencies>)
macro(ut_create_executable)
	add_executable(${the_app} ${UBITRACK_APP_${the_app}_HEADERS} ${UBITRACK_APP_${the_app}_SOURCES})

	set(UBITRACK_APP_${the_module}_COMPILE_DEFINITIONS)

	#MESSAGE(STATUS "${the_app} ${UBITRACK_APP_${the_app}_DEPS} ${UBITRACK_APP_${the_app}_DEPS_EXT} ${UBITRACK_LINKER_LIBS} ${IPP_LIBS} ${ARGN}")
	target_link_libraries(${the_app} ${UBITRACK_APP_${the_app}_DEPS} ${UBITRACK_APP_${the_app}_DEPS_EXT} ${UBITRACK_LINKER_LIBS} ${IPP_LIBS} ${ARGN})

	set_target_properties(${the_app} PROPERTIES
	  OUTPUT_NAME "${the_app}"
	  DEBUG_POSTFIX "${UBITRACK_DEBUG_POSTFIX}"
	  RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}
	  INSTALL_NAME_DIR bin
	)

	# For dynamic link numbering convenions
	#if(NOT ANDROID)
	#  # Android SDK build scripts can include only .so files into final .apk
	#  # As result we should not set version properties for Android
	#  set_target_properties(${the_app} PROPERTIES
	#    VERSION ${UBITRACK_LIBVERSION}
	#    SOVERSION ${UBITRACK_SOVERSION}
	#  )
	#endif()

	  set_target_properties(${the_app} PROPERTIES COMPILE_FLAGS "${UBITRACK_COMPILE_FLAGS}")
	  set_target_properties(${the_app} PROPERTIES LINK_FLAGS "${UBITRACK_LINK_FLAGS}")
	  foreach(_symb ${UBITRACK_DEFINES})
		  set_target_properties(${the_app} PROPERTIES DEFINE_SYMBOL ${_symb})
	  endforeach()

	if (NOT Boost_USE_STATIC_LIBS)
	if(MSVC)
	  # force dynamic linking of boost libs on windows ..
	  set(UBITRACK_APP_${the_app}_COMPILE_DEFINITIONS ${UBITRACK_APP_${the_app}_COMPILE_DEFINITIONS} "BOOST_ALL_DYN_LINK")
	endif(MSVC)
	endif (NOT Boost_USE_STATIC_LIBS)

    set_target_properties(${the_app} PROPERTIES COMPILE_DEFINITIONS "${UBITRACK_APP_${the_app}_COMPILE_DEFINITIONS}")
	  
	if(MSVC)
	  if(CMAKE_CROSSCOMPILING)
	    set_target_properties(${the_app} PROPERTIES LINK_FLAGS "/NODEFAULTLIB:secchk")
	  endif()
	  set_target_properties(${the_app} PROPERTIES LINK_FLAGS "/NODEFAULTLIB:libc /DEBUG")
	endif()

	install(TARGETS ${the_app}
	  RUNTIME DESTINATION bin COMPONENT main
	  )

endmacro()

# creates UbiTrack customized app in current folder
# calls a custom command to configure app
# Usage:
#   ut_create_customized_app()
macro(ut_create_customized_app)
  # the hacky way to allow customized apps to be build .. e.g. swig wrappers
  if(COMMAND ut_get_customized_app_creator)
    ut_get_customized_app_creator()
  endif()	
endmacro()