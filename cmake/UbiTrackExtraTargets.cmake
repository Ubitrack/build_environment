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
