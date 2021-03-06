# Adapted from OpenCV CMake Infrastructure, git repository 05/2013
# by Ulrich Eck
# ----------------------------------------------------------------------------
# Detect Microsoft compiler:
# ----------------------------------------------------------------------------
if(CMAKE_CL_64)
    set(MSVC64 1)
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_COMPILER_IS_GNUCXX 1)
  set(CMAKE_COMPILER_IS_CLANGCXX 1)
endif()
if(CMAKE_C_COMPILER_ID STREQUAL "Clang")
  set(CMAKE_COMPILER_IS_GNUCC 1)
  set(CMAKE_COMPILER_IS_CLANGCC 1)
endif()

if((CMAKE_COMPILER_IS_CLANGCXX OR CMAKE_COMPILER_IS_CLANGCC) AND NOT CMAKE_GENERATOR MATCHES "Xcode")
  set(ENABLE_PRECOMPILED_HEADERS OFF CACHE BOOL "" FORCE)
endif()

# ----------------------------------------------------------------------------
# Detect Intel ICC compiler -- for -fPIC in 3rdparty ( UNIX ONLY ):
#  see  include/opencv/cxtypes.h file for related   ICC & CV_ICC defines.
# NOTE: The system needs to determine if the '-fPIC' option needs to be added
#  for the 3rdparty static libs being compiled.  The CMakeLists.txt files
#  in 3rdparty use the CV_ICC definition being set here to determine if
#  the -fPIC flag should be used.
# ----------------------------------------------------------------------------
if(UNIX)
  if  (__ICL)
    set(CV_ICC   __ICL)
  elseif(__ICC)
    set(CV_ICC   __ICC)
  elseif(__ECL)
    set(CV_ICC   __ECL)
  elseif(__ECC)
    set(CV_ICC   __ECC)
  elseif(__INTEL_COMPILER)
    set(CV_ICC   __INTEL_COMPILER)
  elseif(CMAKE_C_COMPILER MATCHES "icc")
    set(CV_ICC   icc_matches_c_compiler)
  endif()
endif()

if(MSVC AND CMAKE_C_COMPILER MATCHES "icc")
  set(CV_ICC   __INTEL_COMPILER_FOR_WINDOWS)
endif()

# ----------------------------------------------------------------------------
# Detect GNU version:
# ----------------------------------------------------------------------------
if(CMAKE_COMPILER_IS_CLANGCXX)
  set(CMAKE_GCC_REGEX_VERSION "4.2.1")
  set(CMAKE_UBITRACK_GCC_VERSION_MAJOR 4)
  set(CMAKE_UBITRACK_GCC_VERSION_MINOR 2)
  set(CMAKE_UBITRACK_GCC_VERSION 42)
  set(CMAKE_UBITRACK_GCC_VERSION_NUM 402)

  execute_process(COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} -v
                  ERROR_VARIABLE CMAKE_UBITRACK_CLANG_VERSION_FULL
                  ERROR_STRIP_TRAILING_WHITESPACE)

  string(REGEX MATCH "version.*$" CMAKE_UBITRACK_CLANG_VERSION_FULL "${CMAKE_UBITRACK_CLANG_VERSION_FULL}")
  string(REGEX MATCH "[0-9]+\\.[0-9]+" CMAKE_CLANG_REGEX_VERSION "${CMAKE_UBITRACK_CLANG_VERSION_FULL}")

elseif(CMAKE_COMPILER_IS_GNUCXX)
  execute_process(COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} -dumpfullversion -dumpversion
                OUTPUT_VARIABLE CMAKE_UBITRACK_GCC_VERSION_FULL
                OUTPUT_STRIP_TRAILING_WHITESPACE)

  execute_process(COMMAND ${CMAKE_CXX_COMPILER} ${CMAKE_CXX_COMPILER_ARG1} -v
                ERROR_VARIABLE CMAKE_UBITRACK_GCC_INFO_FULL
                OUTPUT_STRIP_TRAILING_WHITESPACE)

  # Typical output in CMAKE_UBITRACK_GCC_VERSION_FULL: "7.2.0"
  # Look for the version number
  string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" CMAKE_GCC_REGEX_VERSION "${CMAKE_UBITRACK_GCC_VERSION_FULL}")
  if(NOT CMAKE_GCC_REGEX_VERSION)
    string(REGEX MATCH "[0-9]+\\.[0-9]+" CMAKE_GCC_REGEX_VERSION "${CMAKE_UBITRACK_GCC_VERSION_FULL}")
  endif()

  # Split the three parts:
  string(REGEX MATCHALL "[0-9]+" CMAKE_UBITRACK_GCC_VERSIONS "${CMAKE_GCC_REGEX_VERSION}")

  list(GET CMAKE_UBITRACK_GCC_VERSIONS 0 CMAKE_UBITRACK_GCC_VERSION_MAJOR)
  list(GET CMAKE_UBITRACK_GCC_VERSIONS 1 CMAKE_UBITRACK_GCC_VERSION_MINOR)

  set(CMAKE_UBITRACK_GCC_VERSION ${CMAKE_UBITRACK_GCC_VERSION_MAJOR}${CMAKE_UBITRACK_GCC_VERSION_MINOR})
  math(EXPR CMAKE_UBITRACK_GCC_VERSION_NUM "${CMAKE_UBITRACK_GCC_VERSION_MAJOR}*100 + ${CMAKE_UBITRACK_GCC_VERSION_MINOR}")
  message(STATUS "Detected version of GNU GCC: ${CMAKE_UBITRACK_GCC_VERSION} (${CMAKE_UBITRACK_GCC_VERSION_NUM})")

  if(WIN32)
    execute_process(COMMAND ${CMAKE_CXX_COMPILER} -dumpmachine
              OUTPUT_VARIABLE CMAKE_UBITRACK_GCC_TARGET_MACHINE
              OUTPUT_STRIP_TRAILING_WHITESPACE)
    if(CMAKE_UBITRACK_GCC_TARGET_MACHINE MATCHES "amd64|x86_64|AMD64")
      set(MINGW64 1)
    endif()
  endif()
endif()

if(MSVC64 OR MINGW64)
  set(X86_64 1)
elseif(MSVC AND NOT CMAKE_CROSSCOMPILING)
  set(X86 1)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "amd64.*|x86_64.*|AMD64.*")
  set(X86_64 1)
elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i686.*|i386.*|x86.*|amd64.*|AMD64.*")
  set(X86 1)
elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "arm.*|ARM.*")
  set(ARM 1)
endif()

if(APPLE)
  execute_process(COMMAND ${CMAKE_CXX_COMPILER} -v
    ERROR_VARIABLE _clangcxx_dumpedversion
    ERROR_STRIP_TRAILING_WHITESPACE
    )
  string(REGEX REPLACE ".*clang version ([0-9]\\.[0-9]+).*" "\\1" _clangcxx_version ${_clangcxx_dumpedversion})
  # Apple Clang 4.2 no longer reports clang version but LLVM version
  # Moreover, this is Apple versioning, not LLVM upstream
  # If this is the case, the previous regex will not do anything.
  # Check to see if we have "Apple LLVM version" in the output,
  # and if so extract the original LLVM version which should appear as
  # "based on LLVM X.Ysvn"
  if(APPLE AND "${_clangcxx_version}" MATCHES ".*Apple LLVM version.*")
    string(REGEX REPLACE ".*based on LLVM ([0-9]\\.[0-9]+)svn.*" "\\1" _clangcxx_version ${_clangcxx_version})
    set(APPLE_CLANG_VERSION ${_clangcxx_version})
    message(STATUS "Apple Clang version: ${_clangcxx_version}")
  endif()
endif(APPLE)
