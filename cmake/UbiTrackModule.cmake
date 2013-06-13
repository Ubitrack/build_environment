# Adapted from OpenCV CMake Infrastructure, git repository 05/2013
# by Ulrich Eck

# Local variables (set for each module):
#
# name       - short name in lower case i.e. core
# the_module - full name in lower case i.e. utcore

# Global variables:
#
# UBITRACK_MODULE_${the_module}_LOCATION
# UBITRACK_MODULE_${the_module}_DESCRIPTION
# UBITRACK_MODULE_${the_module}_CLASS - PUBLIC|INTERNAL|BINDINGS
# UBITRACK_MODULE_${the_module}_HEADERS
# UBITRACK_MODULE_${the_module}_SOURCES
# UBITRACK_MODULE_${the_module}_DEPS - final flattened set of module dependencies
# UBITRACK_MODULE_${the_module}_DEPS_EXT
# UBITRACK_MODULE_${the_module}_REQ_DEPS
# UBITRACK_MODULE_${the_module}_OPT_DEPS
# HAVE_${the_module} - for fast check of module availability

# To control the setup of the module you could also set:
# the_description - text to be used as current module description
# UBITRACK_MODULE_TYPE - STATIC|SHARED - set to force override global settings for current module
# BUILD_${the_module}_INIT - ON|OFF (default ON) - initial value for BUILD_${the_module}

# The verbose template for UbiTrack module:
#
#   ut_add_module(modname <dependencies>)
#   ut_glob_module_sources() or glob them manually and ut_set_module_sources(...)
#   ut_module_include_directories(<extra include directories>)
#   ut_create_module()
#
#
# If module have no "extra" then you can define it in one line:
#
#   ut_define_module(modname <dependencies>)

# clean flags for modules enabled on previous cmake run
# this is necessary to correctly handle modules removal
foreach(mod ${UBITRACK_MODULES_BUILD} ${UBITRACK_MODULES_DISABLED_USER} ${UBITRACK_MODULES_DISABLED_AUTO} ${UBITRACK_MODULES_DISABLED_FORCE})
  if(HAVE_${mod})
    unset(HAVE_${mod} CACHE)
  endif()
  unset(UBITRACK_MODULE_${mod}_REQ_DEPS CACHE)
  unset(UBITRACK_MODULE_${mod}_OPT_DEPS CACHE)
endforeach()

# clean modules info which needs to be recalculated
set(UBITRACK_MODULES_PUBLIC         "" CACHE INTERNAL "List of UbiTrack modules marked for export")
set(UBITRACK_MODULES_BUILD          "" CACHE INTERNAL "List of UbiTrack modules included into the build")
set(UBITRACK_MODULES_DISABLED_USER  "" CACHE INTERNAL "List of UbiTrack modules explicitly disabled by user")
set(UBITRACK_MODULES_DISABLED_AUTO  "" CACHE INTERNAL "List of UbiTrack modules implicitly disabled due to dependencies")
set(UBITRACK_MODULES_DISABLED_FORCE "" CACHE INTERNAL "List of UbiTrack modules which can not be build in current configuration")

# adds dependencies to UbiTrack module
# Usage:
#   add_dependencies(ubitrack_<name> [REQUIRED] [<list of dependencies>] [OPTIONAL <list of modules>])
# Notes:
# * <list of dependencies> - can include full names of modules or full pathes to shared/static libraries or cmake targets
macro(ut_add_dependencies full_modname)
  #we don't clean the dependencies here to allow this macro several times for every module
  foreach(d "REQUIRED" ${ARGN})
    if(d STREQUAL "REQUIRED")
      set(__depsvar UBITRACK_MODULE_${full_modname}_REQ_DEPS)
    elseif(d STREQUAL "OPTIONAL")
      set(__depsvar UBITRACK_MODULE_${full_modname}_OPT_DEPS)
    else()
      list(APPEND ${__depsvar} "${d}")
    endif()
  endforeach()
  unset(__depsvar)

  ut_list_unique(UBITRACK_MODULE_${full_modname}_REQ_DEPS)
  ut_list_unique(UBITRACK_MODULE_${full_modname}_OPT_DEPS)

  set(UBITRACK_MODULE_${full_modname}_REQ_DEPS ${UBITRACK_MODULE_${full_modname}_REQ_DEPS} CACHE INTERNAL "Required dependencies of ${full_modname} module")
  set(UBITRACK_MODULE_${full_modname}_OPT_DEPS ${UBITRACK_MODULE_${full_modname}_OPT_DEPS} CACHE INTERNAL "Optional dependencies of ${full_modname} module")
endmacro()

# declare new UbiTrack module in current folder
# Usage:
#   ut_add_module(<name> [INTERNAL|BINDINGS] [REQUIRED] [<list of dependencies>] [OPTIONAL <list of optional dependencies>])
# Example:
#   ut_add_module(yaom INTERNAL ubitrack_core ubitrack_highgui ubitrack_flann OPTIONAL ubitrack_gpu)
macro(ut_add_module _name)
  string(TOLOWER "${_name}" name)
  set(the_module ${name})

  # the first pass - collect modules info, the second pass - create targets
  if(UBITRACK_INITIAL_PASS)
    #guard agains redefinition
    if(";${UBITRACK_MODULES_BUILD};${UBITRACK_MODULES_DISABLED_USER};" MATCHES ";${the_module};")
      message(FATAL_ERROR "Redefinition of the ${the_module} module.
  at:                    ${CMAKE_CURRENT_SOURCE_DIR}
  previously defined at: ${UBITRACK_MODULE_${the_module}_LOCATION}
")
    endif()

    if(NOT DEFINED the_description)
      set(the_description "The ${name} UbiTrack module")
    endif()

    if(NOT DEFINED BUILD_${the_module}_INIT)
      set(BUILD_${the_module}_INIT ON)
    endif()

    # create option to enable/disable this module
    option(BUILD_${the_module} "Include ${the_module} module into the UbiTrack build" ${BUILD_${the_module}_INIT})

    # remember the module details
    set(UBITRACK_MODULE_${the_module}_DESCRIPTION "${the_description}" CACHE INTERNAL "Brief description of ${the_module} module")
    set(UBITRACK_MODULE_${the_module}_LOCATION    "${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "Location of ${the_module} module sources")
	
    # parse list of dependencies
    if("${ARGV1}" STREQUAL "INTERNAL" OR "${ARGV1}" STREQUAL "BINDINGS")
      set(UBITRACK_MODULE_${the_module}_CLASS "${ARGV1}" CACHE INTERNAL "The cathegory of the module")
      set(__ut_argn__ ${ARGN})
      list(REMOVE_AT __ut_argn__ 0)
      ut_add_dependencies(${the_module} ${__ut_argn__})
      unset(__ut_argn__)
    else()
      set(UBITRACK_MODULE_${the_module}_CLASS "PUBLIC" CACHE INTERNAL "The cathegory of the module")
      ut_add_dependencies(${the_module} ${ARGN})
      if(BUILD_${the_module})
        set(UBITRACK_MODULES_PUBLIC ${UBITRACK_MODULES_PUBLIC} "${the_module}" CACHE INTERNAL "List of UbiTrack modules marked for export")
      endif()
    endif()

    if(BUILD_${the_module})
      set(UBITRACK_MODULES_BUILD ${UBITRACK_MODULES_BUILD} "${the_module}" CACHE INTERNAL "List of UbiTrack modules included into the build")
    else()
      set(UBITRACK_MODULES_DISABLED_USER ${UBITRACK_MODULES_DISABLED_USER} "${the_module}" CACHE INTERNAL "List of UbiTrack modules explicitly disabled by user")
    endif()

    # TODO: add submodules if any

    # stop processing of current file
    return()
  else(UBITRACK_INITIAL_PASS)
    if(NOT BUILD_${the_module})
      return() # extra protection from redefinition
    endif()
    project(${the_module})
  endif(UBITRACK_INITIAL_PASS)
endmacro()

# excludes module from current configuration
macro(ut_module_disable module)
  set(__modname ${module})
  if(NOT __modname MATCHES "^ut")
    set(__modname ubitrack_${module})
  endif()
  list(APPEND UBITRACK_MODULES_DISABLED_FORCE "${__modname}")
  set(HAVE_${__modname} OFF CACHE INTERNAL "Module ${__modname} can not be built in current configuration")
  set(UBITRACK_MODULE_${__modname}_LOCATION "${CMAKE_CURRENT_SOURCE_DIR}" CACHE INTERNAL "Location of ${__modname} module sources")
  set(UBITRACK_MODULES_DISABLED_FORCE "${UBITRACK_MODULES_DISABLED_FORCE}" CACHE INTERNAL "List of UbiTrack modules which can not be build in current configuration")
  if(BUILD_${__modname})
    # touch variable controlling build of the module to suppress "unused variable" CMake warning
  endif()
  unset(__modname)
  return() # leave the current folder
endmacro()


# Internal macro; partly disables UbiTrack module
macro(__ut_module_turn_off the_module)
  list(REMOVE_ITEM UBITRACK_MODULES_DISABLED_AUTO "${the_module}")
  list(APPEND UBITRACK_MODULES_DISABLED_AUTO "${the_module}")
  list(REMOVE_ITEM UBITRACK_MODULES_BUILD "${the_module}")
  list(REMOVE_ITEM UBITRACK_MODULES_PUBLIC "${the_module}")
  set(HAVE_${the_module} OFF CACHE INTERNAL "Module ${the_module} can not be built in current configuration")
endmacro()

# Internal macro for dependencies tracking
macro(__ut_flatten_module_required_dependencies the_module)
  set(__flattened_deps "")
  set(__resolved_deps "")
  set(__req_depends ${UBITRACK_MODULE_${the_module}_REQ_DEPS})

  while(__req_depends)
    ut_list_pop_front(__req_depends __dep)
    if(__dep STREQUAL the_module)
      __ut_module_turn_off(${the_module}) # TODO: think how to deal with cyclic dependency
      break()
    elseif(";${UBITRACK_MODULES_DISABLED_USER};${UBITRACK_MODULES_DISABLED_AUTO};" MATCHES ";${__dep};")
      __ut_module_turn_off(${the_module}) # depends on disabled module
      list(APPEND __flattened_deps "${__dep}")
    elseif(";${UBITRACK_MODULES_BUILD};" MATCHES ";${__dep};")
      if(";${__resolved_deps};" MATCHES ";${__dep};")
        list(APPEND __flattened_deps "${__dep}") # all dependencies of this module are already resolved
      else()
        # put all required subdependencies before this dependency and mark it as resolved
        list(APPEND __resolved_deps "${__dep}")
        list(INSERT __req_depends 0 ${UBITRACK_MODULE_${__dep}_REQ_DEPS} ${__dep})
      endif()
    elseif(__dep MATCHES "^ut")
	  __ut_module_turn_off(${the_module}) # depends on missing module
      message(WARNING "Unknown \"${__dep}\" module is listened in the dependencies of \"${the_module}\" module")
      break()
    else()
      # skip non-modules
    endif()
  endwhile()

  if(__flattened_deps)
    list(REMOVE_DUPLICATES __flattened_deps)
    set(UBITRACK_MODULE_${the_module}_DEPS ${__flattened_deps})
  else()
    set(UBITRACK_MODULE_${the_module}_DEPS "")
  endif()

  ut_clear_vars(__resolved_deps __flattened_deps __req_depends __dep)
endmacro()

# Internal macro for dependencies tracking
macro(__ut_flatten_module_optional_dependencies the_module)
  set(__flattened_deps "")
  set(__resolved_deps "")
  set(__opt_depends ${UBITRACK_MODULE_${the_module}_REQ_DEPS} ${UBITRACK_MODULE_${the_module}_OPT_DEPS})

  while(__opt_depends)
    ut_list_pop_front(__opt_depends __dep)
    if(__dep STREQUAL the_module)
      __ut_module_turn_off(${the_module}) # TODO: think how to deal with cyclic dependency
      break()
    elseif(";${UBITRACK_MODULES_BUILD};" MATCHES ";${__dep};")
      if(";${__resolved_deps};" MATCHES ";${__dep};")
        list(APPEND __flattened_deps "${__dep}") # all dependencies of this module are already resolved
      else()
        # put all subdependencies before this dependency and mark it as resolved
        list(APPEND __resolved_deps "${__dep}")
        list(INSERT __opt_depends 0 ${UBITRACK_MODULE_${__dep}_REQ_DEPS} ${UBITRACK_MODULE_${__dep}_OPT_DEPS} ${__dep})
      endif()
    else()
      # skip non-modules or missing modules
    endif()
  endwhile()

  if(__flattened_deps)
    list(REMOVE_DUPLICATES __flattened_deps)
    set(UBITRACK_MODULE_${the_module}_DEPS ${__flattened_deps})
  else()
    set(UBITRACK_MODULE_${the_module}_DEPS "")
  endif()

  ut_clear_vars(__resolved_deps __flattened_deps __opt_depends __dep)
endmacro()

macro(__ut_flatten_module_dependencies)
  foreach(m ${UBITRACK_MODULES_DISABLED_USER})
    set(HAVE_${m} OFF CACHE INTERNAL "Module ${m} will not be built in current configuration")
  endforeach()
  foreach(m ${UBITRACK_MODULES_BUILD})
    set(HAVE_${m} ON CACHE INTERNAL "Module ${m} will be built in current configuration")
    __ut_flatten_module_required_dependencies(${m})
    set(UBITRACK_MODULE_${m}_DEPS ${UBITRACK_MODULE_${m}_DEPS} CACHE INTERNAL "Flattened required dependencies of ${m} module")
  endforeach()

  foreach(m ${UBITRACK_MODULES_BUILD})
    __ut_flatten_module_optional_dependencies(${m})

    # save dependencies from other modules
    set(UBITRACK_MODULE_${m}_DEPS ${UBITRACK_MODULE_${m}_DEPS} CACHE INTERNAL "Flattened dependencies of ${m} module")
    # save extra dependencies
    set(UBITRACK_MODULE_${m}_DEPS_EXT ${UBITRACK_MODULE_${m}_REQ_DEPS} ${UBITRACK_MODULE_${m}_OPT_DEPS})
    if(UBITRACK_MODULE_${m}_DEPS_EXT AND UBITRACK_MODULE_${m}_DEPS)
      list(REMOVE_ITEM UBITRACK_MODULE_${m}_DEPS_EXT ${UBITRACK_MODULE_${m}_DEPS})
    endif()
    ut_list_filterout(UBITRACK_MODULE_${m}_DEPS_EXT "^ut[^ ]+$")
    set(UBITRACK_MODULE_${m}_DEPS_EXT ${UBITRACK_MODULE_${m}_DEPS_EXT} CACHE INTERNAL "Extra dependencies of ${m} module")
  endforeach()

  # order modules by dependencies
  set(UBITRACK_MODULES_BUILD_ "")
  foreach(m ${UBITRACK_MODULES_BUILD})
    list(APPEND UBITRACK_MODULES_BUILD_ ${UBITRACK_MODULE_${m}_DEPS} ${m})
  endforeach()
  ut_list_unique(UBITRACK_MODULES_BUILD_)

  set(UBITRACK_MODULES_PUBLIC        ${UBITRACK_MODULES_PUBLIC}        CACHE INTERNAL "List of UbiTrack modules marked for export")
  set(UBITRACK_MODULES_BUILD         ${UBITRACK_MODULES_BUILD_}        CACHE INTERNAL "List of UbiTrack modules included into the build")
  set(UBITRACK_MODULES_DISABLED_AUTO ${UBITRACK_MODULES_DISABLED_AUTO} CACHE INTERNAL "List of UbiTrack modules implicitly disabled due to dependencies")
endmacro()

# collect modules from specified directories
# NB: must be called only once!
macro(ut_glob_modules)
  if(DEFINED UBITRACK_INITIAL_PASS)
    message(FATAL_ERROR "UbiTrack has already loaded its modules. Calling ut_glob_modules second time is not allowed.")
  endif()
  set(__directories_observed "")

  # collect modules
  set(UBITRACK_INITIAL_PASS ON)
  foreach(__path ${ARGN})
    ut_get_real_path(__path "${__path}")

    list(FIND __directories_observed "${__path}" __pathIdx)
    if(__pathIdx GREATER -1)
      message(FATAL_ERROR "The directory ${__path} is observed for UbiTrack modules second time.")
    endif()
    list(APPEND __directories_observed "${__path}")

    file(GLOB __utmodules RELATIVE "${__path}" "${__path}/*")
    if(__utmodules)
      list(SORT __utmodules)
      foreach(mod ${__utmodules})
        ut_get_real_path(__modpath "${__path}/${mod}")
        if(EXISTS "${__modpath}/CMakeLists.txt")

          list(FIND __directories_observed "${__modpath}" __pathIdx)
          if(__pathIdx GREATER -1)
            message(FATAL_ERROR "The module from ${__modpath} is already loaded.")
          endif()
          list(APPEND __directories_observed "${__modpath}")

          add_subdirectory("${__modpath}" "${CMAKE_CURRENT_BINARY_DIR}/${mod}/.${mod}")
        endif()
      endforeach()
    endif()
  endforeach()
  ut_clear_vars(__utmodules __directories_observed __path __modpath __pathIdx)

  # resolve dependencies
  __ut_flatten_module_dependencies()

  # create modules
  set(UBITRACK_INITIAL_PASS OFF PARENT_SCOPE)
  set(UBITRACK_INITIAL_PASS OFF)
  
  foreach(m ${UBITRACK_MODULES_BUILD})
      add_subdirectory("${UBITRACK_MODULE_${m}_LOCATION}" "${CMAKE_CURRENT_BINARY_DIR}/${m}")
  endforeach()
  foreach(m ${UBITRACK_COMPONENTS_BUILD})
      add_subdirectory("${UBITRACK_COMPONENT_${m}_LOCATION}" "${CMAKE_CURRENT_BINARY_DIR}/${m}")
  endforeach()
  foreach(m ${UBITRACK_APPS_BUILD})
      add_subdirectory("${UBITRACK_APP_${m}_LOCATION}" "${CMAKE_CURRENT_BINARY_DIR}/${m}")
  endforeach()

  unset(__shortname)
endmacro()

# setup include paths for the list of passed modules
macro(ut_include_modules)
  foreach(d ${ARGN})
    if(HAVE_${d})
      if (EXISTS "${UBITRACK_MODULE_${d}_LOCATION}/src")
        ut_include_directories("${UBITRACK_MODULE_${d}_LOCATION}/src")
      elseif (EXISTS "${UBITRACK_MODULES_PATH}/${d}/src")
        ut_include_directories("${UBITRACK_MODULES_PATH}/${d}/src")
  	  else()
	    MESSAGE(STATUS "MISSING MODULE_INCLUDE: ${d} - ${UBITRACK_MODULE_${d}_LOCATION}")
      endif()
    elseif (EXISTS "${UBITRACK_MODULES_PATH}/${d}/src")
      ut_include_directories("${UBITRACK_MODULES_PATH}/${d}/src")
    elseif(EXISTS "${d}")
      ut_include_directories("${d}")
    endif()
  endforeach()
endmacro()

# setup include paths for the list of passed modules and recursively add dependent modules
macro(ut_include_modules_recurse)
  foreach(d ${ARGN})
    if(HAVE_${d})
      if (EXISTS "${UBITRACK_MODULE_${d}_LOCATION}/src")
        ut_include_directories("${UBITRACK_MODULE_${d}_LOCATION}/src")
      endif()
      if(UBITRACK_MODULE_${d}_DEPS)
        ut_include_modules_recurse(${UBITRACK_MODULE_${d}_DEPS})
      endif()
    elseif(EXISTS "${d}")
      ut_include_directories("${d}")
    endif()
  endforeach()
endmacro()

# setup include path for UbiTrack headers for specified module
# ut_module_include_directories(<extra include directories/extra include modules>)
macro(ut_module_include_directories)
  ut_include_directories( "${UBITRACK_MODULE_${the_module}_LOCATION}/src"
                          "${CMAKE_CURRENT_BINARY_DIR}/src" # for precompiled headers
                          )
  ut_include_modules(${UBITRACK_MODULE_${the_module}_DEPS} ${ARGN})
endmacro()


# sets header and source files for the current module
# NB: all files specified as headers will be installed
# Usage:
# ut_set_module_sources([HEADERS] <list of files> [SOURCES] <list of files>)
macro(ut_set_module_sources)
  set(UBITRACK_MODULE_${the_module}_HEADERS "")
  set(UBITRACK_MODULE_${the_module}_SOURCES "")

  foreach(f "HEADERS" ${ARGN})
	# ignore filenames, which contain *
	if(f MATCHES "^.*[*].*$")
		# ignore
    elseif(f STREQUAL "HEADERS" OR f STREQUAL "SOURCES")
      set(__filesvar "UBITRACK_MODULE_${the_module}_${f}")
    else()
      list(APPEND ${__filesvar} "${f}")
    endif()
  endforeach()

  # the hacky way to embeed any files into the UbiTrack without modification of its build system
  if(COMMAND ut_get_module_external_sources)
    ut_get_module_external_sources()
  endif()

  # use full paths for module to be independent from the module location
  ut_convert_to_full_paths(UBITRACK_MODULE_${the_module}_HEADERS)

  set(UBITRACK_MODULE_${the_module}_HEADERS ${UBITRACK_MODULE_${the_module}_HEADERS} CACHE INTERNAL "List of header files for ${the_module}")
  set(UBITRACK_MODULE_${the_module}_SOURCES ${UBITRACK_MODULE_${the_module}_SOURCES} CACHE INTERNAL "List of source files for ${the_module}")
endmacro()

# finds and sets headers and sources for the standard UbiTrack module
# Usage:
# ut_glob_module_sources(<extra sources&headers in the same format as used in ut_set_module_sources>)
macro(ut_glob_module_sources)
  set(UBITRACK_MODULE_${the_module}_GLOB_HEADERS "")
  set(UBITRACK_MODULE_${the_module}_GLOB_SOURCES "")

  foreach(f "HEADERS" ${ARGN})
	if(f STREQUAL "HEADERS" OR f STREQUAL "SOURCES")
      set(__filesvar "UBITRACK_MODULE_${the_module}_GLOB_${f}")
    else()
      list(APPEND ${__filesvar} "${f}")
    endif()
  endforeach()
	
	
  file(GLOB lib_srcs ${UBITRACK_MODULE_${the_module}_GLOB_SOURCES})
  file(GLOB lib_hdrs ${UBITRACK_MODULE_${the_module}_GLOB_HEADERS})
  ut_set_module_sources(HEADERS ${lib_hdrs}
                        SOURCES ${lib_srcs})

  source_group("Src" FILES ${lib_srcs})
  source_group("Include" FILES ${lib_hdrs})
endmacro()

# creates UbiTrack module in current folder
# creates new target, configures standard dependencies, compilers flags, install rules
# Usage:
#   ut_create_module(<extra link dependencies>)
#   ut_create_module(SKIP_LINK)
macro(ut_create_module)
	add_library(${the_module} ${UBITRACK_MODULE_TYPE} ${UBITRACK_MODULE_${the_module}_HEADERS} ${UBITRACK_MODULE_${the_module}_SOURCES})
	#set_target_properties(${the_module} PROPERTIES COMPILE_DEFINITIONS UBITRACK_NOSTL)

	if(NOT "${ARGN}" STREQUAL "SKIP_LINK")
	#MESSAGE(STATUS "${the_module} ${UBITRACK_MODULE_${the_module}_DEPS} ${UBITRACK_MODULE_${the_module}_DEPS_EXT} ${UBITRACK_LINKER_LIBS} ${IPP_LIBS} ${ARGN}")
	  target_link_libraries(${the_module} ${UBITRACK_MODULE_${the_module}_DEPS} ${UBITRACK_MODULE_${the_module}_DEPS_EXT} ${UBITRACK_LINKER_LIBS} ${IPP_LIBS} ${ARGN})

	  #if (HAVE_CUDA)
	  #  target_link_libraries(${the_module} ${CUDA_LIBRARIES} ${CUDA_npp_LIBRARY})
	  #endif()
	  #if(HAVE_OPENCL AND OPENCL_LIBRARIES)
	  #  target_link_libraries(${the_module} ${OPENCL_LIBRARIES})
	  #endif()
	endif()

	add_dependencies(ubitrack_modules ${the_module})

	set_target_properties(${the_module} PROPERTIES
	  OUTPUT_NAME "${the_module}${UBITRACK_DLLVERSION}"
	  DEBUG_POSTFIX "${UBITRACK_DEBUG_POSTFIX}"
	  ARCHIVE_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH}
	  LIBRARY_OUTPUT_DIRECTORY ${LIBRARY_OUTPUT_PATH}
	  RUNTIME_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH}
	  INSTALL_NAME_DIR lib
	)

	# For dynamic link numbering convenions
	if(NOT ANDROID)
	  # Android SDK build scripts can include only .so files into final .apk
	  # As result we should not set version properties for Android
	  set_target_properties(${the_module} PROPERTIES
	    VERSION ${UBITRACK_LIBVERSION}
	    SOVERSION ${UBITRACK_SOVERSION}
	  )
	endif()

	if(BUILD_SHARED_LIBS)
	  if(MSVC)
	    string(TOUPPER "${the_module}" the_module_upper)
	    #set_target_properties(${the_module} PROPERTIES DEFINE_SYMBOL "${the_module_upper}_DLL")
	    add_definitions( "-D${the_module_upper}_DLL")
	  endif()
	endif()

	if(MSVC)
	  if(CMAKE_CROSSCOMPILING)
	    set_target_properties(${the_module} PROPERTIES LINK_FLAGS "/NODEFAULTLIB:secchk")
	  endif()
	  set_target_properties(${the_module} PROPERTIES LINK_FLAGS "/NODEFAULTLIB:libc /DEBUG")

	  set_target_properties(${the_module} PROPERTIES COMPILE_FLAGS "${UBITRACK_COMPILE_FLAGS}")
	  set_target_properties(${the_module} PROPERTIES LINK_FLAGS "${UBITRACK_LINK_FLAGS}")
	  foreach(_symb ${UBITRACK_DEFINES})
		  set_target_properties(${the_module} PROPERTIES DEFINE_SYMBOL ${_symb})
	  endforeach()
    endif()

	install(TARGETS ${the_module}
	  RUNTIME DESTINATION bin COMPONENT main
	  LIBRARY DESTINATION ${UBITRACK_LIB_INSTALL_PATH} COMPONENT main
	  ARCHIVE DESTINATION ${UBITRACK_LIB_INSTALL_PATH} COMPONENT main
	  )

	# only "public" headers need to be installed
	if(UBITRACK_MODULE_${the_module}_HEADERS AND ";${UBITRACK_MODULES_PUBLIC};" MATCHES ";${the_module};")
	  foreach(hdr ${UBITRACK_MODULE_${the_module}_HEADERS})
	    string(REGEX REPLACE "^.*modules/.*/src/" "" hdr2 "${hdr}")
	           GET_FILENAME_COMPONENT(fpath ${hdr2} PATH)
	           #MESSAGE(STATUS "${UBITRACK_INCLUDE_INSTALL_PATH}/${fpath}")
	           IF(fpath)
	      install(FILES ${hdr} DESTINATION "${UBITRACK_INCLUDE_INSTALL_PATH}/${fpath}" COMPONENT main)
	           ELSE(fpath)
	             install(FILES ${hdr} DESTINATION "${UBITRACK_INCLUDE_INSTALL_PATH}" COMPONENT main)
	           ENDIF(fpath)
	  endforeach()
	endif()

endmacro()

macro(ut_install_utql_patterns)
	# collect all utql patterns from module for installation
    file(GLOB _utql_patterns "doc/utql/*.xml" "doc/utql/*/*.xml"  "doc/utql/*/*/*.xml")
    foreach(pfile ${_utql_patterns})
      string(REGEX REPLACE "^.*/doc/utql/" "" pfile2 "${pfile}")
      GET_FILENAME_COMPONENT(fpath ${pfile2} PATH)
      IF(fpath)
    	install(FILES ${pfile} DESTINATION "${UBITRACK_UTQLPATTERN_INSTALL_DIRECTORY}/${fpath}" COMPONENT main)
      ELSE(fpath)
        install(FILES ${pfile} DESTINATION "${UBITRACK_UTQLPATTERN_INSTALL_DIRECTORY}" COMPONENT main)
      ENDIF(fpath)
    endforeach()
endmacro()

# short command for adding simple UbiTrack module
# see ut_add_module for argument details
# Usage:
# ut_define_module(module_name  [INTERNAL] [REQUIRED] [<list of dependencies>] [OPTIONAL <list of optional dependencies>])
macro(ut_define_module module_name)
  ut_add_module(${module_name} ${ARGN})
  ut_module_include_directories()
  ut_glob_module_sources()
  ut_create_module()
endmacro()

# ensures that all passed modules are available
# sets UT_DEPENDENCIES_FOUND variable to TRUE/FALSE
macro(ut_check_dependencies)
  set(UT_DEPENDENCIES_FOUND TRUE)
  foreach(d ${ARGN})
    if(NOT HAVE_${d})
      set(UT_DEPENDENCIES_FOUND FALSE)
      break()
    endif()
  endforeach()
endmacro()

# internal macro; finds all link dependencies of the module
# should be used at the end of CMake processing
macro(__ut_track_module_link_dependencies the_module optkind)
  set(${the_module}_MODULE_DEPS_${optkind}   "")
  set(${the_module}_EXTRA_DEPS_${optkind}    "")

  get_target_property(__module_type ${the_module} TYPE)
  if(__module_type STREQUAL "STATIC_LIBRARY")
    #in case of static library we have to inherit its dependencies (in right order!!!)
    if(NOT DEFINED ${the_module}_LIB_DEPENDS_${optkind})
      ut_split_libs_list(${the_module}_LIB_DEPENDS ${the_module}_LIB_DEPENDS_DBG ${the_module}_LIB_DEPENDS_OPT)
    endif()

    set(__resolved_deps "")
    set(__mod_depends ${${the_module}_LIB_DEPENDS_${optkind}})
    set(__has_cycle FALSE)

    while(__mod_depends)
      list(GET __mod_depends 0 __dep)
      list(REMOVE_AT __mod_depends 0)
      if(__dep STREQUAL the_module)
        set(__has_cycle TRUE)
      else()#if("${UBITRACK_MODULES_BUILD}" MATCHES "(^|;)${__dep}(;|$)")
        ut_regex_escape(__rdep "${__dep}")
        if(__resolved_deps MATCHES "(^|;)${__rdep}(;|$)")
          #all dependencies of this module are already resolved
          list(APPEND ${the_module}_MODULE_DEPS_${optkind} "${__dep}")
        else()
          get_target_property(__module_type ${__dep} TYPE)
          if(__module_type STREQUAL "STATIC_LIBRARY")
            if(NOT DEFINED ${__dep}_LIB_DEPENDS_${optkind})
              ut_split_libs_list(${__dep}_LIB_DEPENDS ${__dep}_LIB_DEPENDS_DBG ${__dep}_LIB_DEPENDS_OPT)
            endif()
            list(INSERT __mod_depends 0 ${${__dep}_LIB_DEPENDS_${optkind}} ${__dep})
            list(APPEND __resolved_deps "${__dep}")
          elseif(NOT __module_type)
            list(APPEND  ${the_module}_EXTRA_DEPS_${optkind} "${__dep}")
          endif()
        endif()
      #else()
       # get_target_property(__dep_location "${__dep}" LOCATION)
      endif()
    endwhile()

    ut_list_unique(${the_module}_MODULE_DEPS_${optkind})
    #ut_list_reverse(${the_module}_MODULE_DEPS_${optkind})
    ut_list_unique(${the_module}_EXTRA_DEPS_${optkind})
    #ut_list_reverse(${the_module}_EXTRA_DEPS_${optkind})

    if(__has_cycle)
      # not sure if it can work
      list(APPEND ${the_module}_MODULE_DEPS_${optkind} "${the_module}")
    endif()

    unset(__dep_location)
    unset(__mod_depends)
    unset(__resolved_deps)
    unset(__has_cycle)
    unset(__rdep)
  endif()#STATIC_LIBRARY
  unset(__module_type)

  #message("${the_module}_MODULE_DEPS_${optkind}")
  #message("       ${${the_module}_MODULE_DEPS_${optkind}}")
  #message("       ${UBITRACK_MODULE_${the_module}_DEPS}")
  #message("")
  #message("${the_module}_EXTRA_DEPS_${optkind}")
  #message("       ${${the_module}_EXTRA_DEPS_${optkind}}")
  #message("")
endmacro()

# creates lists of build dependencies needed for external projects
macro(ut_track_build_dependencies)
  foreach(m ${UBITRACK_MODULES_BUILD})
    __ut_track_module_link_dependencies("${m}" OPT)
    __ut_track_module_link_dependencies("${m}" DBG)
  endforeach()
endmacro()
