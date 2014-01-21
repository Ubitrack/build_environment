# ----------------------------------------------------------------------------
#   Uninstall target, for "make uninstall"
# ----------------------------------------------------------------------------
#CONFIGURE_FILE(
#  "${UbiTrack_SOURCE_DIR}/cmake/templates/cmake_uninstall.cmake.in"
#  "${CMAKE_CURRENT_BINARY_DIR}/cmake_uninstall.cmake"
#  IMMEDIATE @ONLY)


# ----------------------------------------------------------------------------
# target building all UbiTrack modules
# ----------------------------------------------------------------------------
add_custom_target(ubitrack_modules)


if(BUILD_TESTS)
  add_custom_target(ubitrack_tests)
  if(ENABLE_SOLUTION_FOLDERS)
    set_target_properties(ubitrack_tests PROPERTIES FOLDER "extra")
  endif()
endif()