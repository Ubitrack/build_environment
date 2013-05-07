# Adapted from OpenCV CMake Infrastructure, git repository 05/2013
# by Ulrich Eck

if(ANDROID)
  # --------------------------------------------------------------------------------------------
  #  Installation for Android ndk-build makefile:  UbiTrack.mk
  #  Part 1/2: ${BIN_DIR}/UbiTrack.mk              -> For use *without* "make install"
  #  Part 2/2: ${BIN_DIR}/unix-install/UbiTrack.mk -> For use with "make install"
  # -------------------------------------------------------------------------------------------

  # build type
  if(BUILD_SHARED_LIBS)
    set(UBITRACK_LIBTYPE_CONFIGMAKE "SHARED")
  else()
    set(UBITRACK_LIBTYPE_CONFIGMAKE "STATIC")
  endif()

  if(BUILD_FAT_JAVA_LIB)
    set(UBITRACK_LIBTYPE_CONFIGMAKE "SHARED")
    set(UBITRACK_STATIC_LIBTYPE_CONFIGMAKE "STATIC")
  else()
    set(UBITRACK_STATIC_LIBTYPE_CONFIGMAKE ${UBITRACK_LIBTYPE_CONFIGMAKE})
  endif()

  # setup lists of camera libs
  foreach(abi ARMEABI ARMEABI_V7A X86 MIPS)
    ANDROID_GET_ABI_RAWNAME(${abi} ndkabi)
    if(BUILD_ANDROID_CAMERA_WRAPPER)
      if(ndkabi STREQUAL ANDROID_NDK_ABI_NAME)
        set(UBITRACK_CAMERA_LIBS_${abi}_CONFIGCMAKE "native_camera_r${ANDROID_VERSION}")
      else()
        set(UBITRACK_CAMERA_LIBS_${abi}_CONFIGCMAKE "")
      endif()
    elseif(HAVE_opencv_androidcamera)
      set(UBITRACK_CAMERA_LIBS_${abi}_CONFIGCMAKE "")
      file(GLOB UBITRACK_CAMERA_LIBS "${UbiTrack_SOURCE_DIR}/3rdparty/lib/${ndkabi}/libnative_camera_r*.so")
      if(UBITRACK_CAMERA_LIBS)
        list(SORT UBITRACK_CAMERA_LIBS)
      endif()
      foreach(cam_lib ${UBITRACK_CAMERA_LIBS})
        get_filename_component(cam_lib "${cam_lib}" NAME)
        string(REGEX REPLACE "lib(native_camera_r[0-9]+\\.[0-9]+\\.[0-9]+)\\.so" "\\1" cam_lib "${cam_lib}")
        set(UBITRACK_CAMERA_LIBS_${abi}_CONFIGCMAKE "${UBITRACK_CAMERA_LIBS_${abi}_CONFIGCMAKE} ${cam_lib}")
      endforeach()
    endif()
  endforeach()

  # build the list of opencv libs and dependencies for all modules
  set(UBITRACK_MODULES_CONFIGMAKE "")
  set(UBITRACK_EXTRA_COMPONENTS_CONFIGMAKE "")
  set(UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE "")
  foreach(m ${UBITRACK_MODULES_PUBLIC})
    list(INSERT UBITRACK_MODULES_CONFIGMAKE 0 ${${m}_MODULE_DEPS_${ocv_optkind}} ${m})
    if(${m}_EXTRA_DEPS_${ocv_optkind})
      list(INSERT UBITRACK_EXTRA_COMPONENTS_CONFIGMAKE 0 ${${m}_EXTRA_DEPS_${ocv_optkind}})
    endif()
  endforeach()

  # split 3rdparty libs and modules
  foreach(mod ${UBITRACK_MODULES_CONFIGMAKE})
    if(NOT mod MATCHES "^opencv_.+$")
      list(INSERT UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE 0 ${mod})
    endif()
  endforeach()
  if(UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE)
    list(REMOVE_ITEM UBITRACK_MODULES_CONFIGMAKE ${UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE})
  endif()

  # convert CMake lists to makefile literals
  foreach(lst UBITRACK_MODULES_CONFIGMAKE UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE UBITRACK_EXTRA_COMPONENTS_CONFIGMAKE)
    ocv_list_unique(${lst})
    ocv_list_reverse(${lst})
    string(REPLACE ";" " " ${lst} "${${lst}}")
  endforeach()
  string(REPLACE "opencv_" "" UBITRACK_MODULES_CONFIGMAKE "${UBITRACK_MODULES_CONFIGMAKE}")

  # prepare 3rd-party component list without TBB for armeabi and mips platforms. TBB is useless there.
  set(UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE_NO_TBB ${UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE})
  foreach(mod ${UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE_NO_TBB})
     string(REPLACE "tbb" "" UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE_NO_TBB "${UBITRACK_3RDPARTY_COMPONENTS_CONFIGMAKE_NO_TBB}")
  endforeach()

  if(BUILD_FAT_JAVA_LIB)
    set(UBITRACK_LIBS_CONFIGMAKE java)
  else()
    set(UBITRACK_LIBS_CONFIGMAKE "${UBITRACK_MODULES_CONFIGMAKE}")
  endif()

  # -------------------------------------------------------------------------------------------
  #  Part 1/2: ${BIN_DIR}/UbiTrack.mk              -> For use *without* "make install"
  # -------------------------------------------------------------------------------------------
  set(UBITRACK_INCLUDE_DIRS_CONFIGCMAKE "\"${UBITRACK_CONFIG_FILE_INCLUDE_DIR}\" \"${UbiTrack_SOURCE_DIR}/include\" \"${UbiTrack_SOURCE_DIR}/include/opencv\"")
  set(UBITRACK_BASE_INCLUDE_DIR_CONFIGCMAKE "\"${UbiTrack_SOURCE_DIR}\"")
  set(UBITRACK_LIBS_DIR_CONFIGCMAKE "\$(UBITRACK_THIS_DIR)/lib/\$(UBITRACK_TARGET_ARCH_ABI)")
  set(UBITRACK_3RDPARTY_LIBS_DIR_CONFIGCMAKE "\$(UBITRACK_THIS_DIR)/3rdparty/lib/\$(UBITRACK_TARGET_ARCH_ABI)")

  configure_file("${UbiTrack_SOURCE_DIR}/cmake/templates/UbiTrack.mk.in" "${CMAKE_BINARY_DIR}/UbiTrack.mk" IMMEDIATE @ONLY)

  # -------------------------------------------------------------------------------------------
  #  Part 2/2: ${BIN_DIR}/unix-install/UbiTrack.mk -> For use with "make install"
  # -------------------------------------------------------------------------------------------
  set(UBITRACK_INCLUDE_DIRS_CONFIGCMAKE "\"\$(LOCAL_PATH)/\$(UBITRACK_THIS_DIR)/include/opencv\" \"\$(LOCAL_PATH)/\$(UBITRACK_THIS_DIR)/include\"")
  set(UBITRACK_BASE_INCLUDE_DIR_CONFIGCMAKE "")
  set(UBITRACK_LIBS_DIR_CONFIGCMAKE "\$(UBITRACK_THIS_DIR)/../libs/\$(UBITRACK_TARGET_ARCH_ABI)")
  set(UBITRACK_3RDPARTY_LIBS_DIR_CONFIGCMAKE "\$(UBITRACK_THIS_DIR)/../3rdparty/libs/\$(UBITRACK_TARGET_ARCH_ABI)")

  configure_file("${UbiTrack_SOURCE_DIR}/cmake/templates/UbiTrack.mk.in" "${CMAKE_BINARY_DIR}/unix-install/UbiTrack.mk" IMMEDIATE @ONLY)
  install(FILES ${CMAKE_BINARY_DIR}/unix-install/UbiTrack.mk DESTINATION ${UBITRACK_CONFIG_INSTALL_PATH})
endif(ANDROID)
