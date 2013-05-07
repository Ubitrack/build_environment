# - Try to find OpenCV library installation
# See http://sourceforge.net/projects/opencvlibrary/
#
# The follwoing variables are optionally searched for defaults
#  OpenCV_ROOT_DIR:            Base directory of OpenCv tree to use.
#  OpenCV_FIND_REQUIRED_COMPONENTS : FIND_PACKAGE(OpenCV COMPONENTS ..) 
#    compatible interface. typically  CV CXCORE CVAUX HIGHGUI ML .. etc.
#
# The following are set after configuration is done: 
#  OpenCV_FOUND
#  OpenCV_INCLUDE_DIR
#  OpenCV_LIBRARIES
#  OpenCV_LINK_DIRECTORIES
#
# 2004/05 Jan Woetzel, Friso, Daniel Grest 
# 2006/01 complete rewrite by Jan Woetzel
# 2006/09 2nd rewrite introducing ROOT_DIR and PATH_SUFFIXES 
#   to handle multiple installed versions gracefully by Jan Woetzel
# 2009/05 modified by Michal Spanel for OpenCV 2.0
# 2010/11 modified by Michal Spanel for OpenCV 2.1
# 2011/03 modified by Ulrich Eck for OpenCV 2.2
#
# tested with:
# - OpenCV 2.0 beta:  MSVC 9.0
# - OpenCV 2.1:  MSVC 9.0
#
# www.mip.informatik.uni-kiel.de/~jw
# --------------------------------
# all COMPONENTS: CORE IMGPROC HIGHGUI ML FEATURES2D VIDEO OBJDETECT CALIB3D FLANN CONTRIB LEGACY GPU


# required cv components with header and library if COMPONENTS unspecified
IF (NOT OpenCV_FIND_COMPONENTS)
  # default
  SET(OpenCV_FIND_REQUIRED_COMPONENTS CORE IMGPROC HIGHGUI ML FEATURES2D VIDEO OBJDETECT CALIB3D FLANN )
ENDIF (NOT OpenCV_FIND_COMPONENTS)

#SET(OpenCV_FIND_REQUIRED_COMPONENTS CORE IMGPROC HIGHGUI OBJDETECT )


# Try to find OpenCV on Windows
#get_filename_component( OpenCV_POSSIBLE_ROOT_DIR
#  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenCV1.2;UninstallString]"
#  PATH
#  )
get_filename_component( OpenCV_POSSIBLE_ROOT_DIR
  "[HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\OpenCV2.2;UninstallString]"
  PATH
  )

# typical root dirs of installations, exactly one of them is used
SET (OpenCV_POSSIBLE_ROOT_DIRS
  "$ENV{H3D_EXTERNAL_ROOT}"
  "$ENV{H3D_ROOT}/../External"    
  "${OpenCV_ROOT_DIR}"
  "$ENV{OpenCV_ROOT_DIR}"
  "${OpenCV_POSSIBLE_ROOT_DIR}"
  "$ENV{ProgramFiles}/OpenCV"
  "C:/deps/OpenCV-2.2.0/build"
  "C:/deps/OpenCV-2.2.0"
  "C:/OpenCV"
  "D:/OpenCV"
  /usr/local
  /opt/local
  /usr
  )


#
# select exactly ONE OpenCV base directory/tree 
# to avoid mixing different version headers and libs
#
FIND_PATH(OpenCV_ROOT_DIR 
  NAMES 
  include/opencv2/opencv.hpp
  PATHS ${OpenCV_POSSIBLE_ROOT_DIRS}
  )


# header include dir suffixes appended to OpenCV_ROOT_DIR
SET(OpenCV_INCDIR_SUFFIXES
  include
  )


# library linkdir suffixes appended to OpenCV_ROOT_DIR 
SET(OpenCV_LIBDIR_SUFFIXES
  lib
  lib32
  OpenCV/lib
  build/lib
  )


#
# find incdir for each lib
# 
FIND_PATH(OpenCV_CV_INCLUDE_DIR
  NAMES opencv2/opencv.hpp      
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_CORE_INCLUDE_DIR   
  NAMES opencv2/core/core.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_IMGPROC_INCLUDE_DIR    
  NAMES opencv2/imgproc/imgproc.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_HIGHGUI_INCLUDE_DIR  
  NAMES opencv2/highgui/highgui.hpp 
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_ML_INCLUDE_DIR    
  NAMES opencv2/ml/ml.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_FEATURES2D_INCLUDE_DIR    
  NAMES opencv2/features2d/features2d.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_VIDEO_INCLUDE_DIR    
  NAMES opencv2/video/tracking.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_OBJDETECT_INCLUDE_DIR    
  NAMES opencv2/objdetect/objdetect.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_CALIB3D_INCLUDE_DIR    
  NAMES opencv2/calib3d/calib3d.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_FLANN_INCLUDE_DIR    
  NAMES opencv2/flann/flann.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_CONTRIB_INCLUDE_DIR    
  NAMES opencv2/contrib/contrib.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_LEGACY_INCLUDE_DIR    
  NAMES opencv2/legacy/legacy.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )
FIND_PATH(OpenCV_GPU_INCLUDE_DIR    
  NAMES opencv2/gpu/gpu.hpp
  PATHS ${OpenCV_ROOT_DIR} 
  PATH_SUFFIXES ${OpenCV_INCDIR_SUFFIXES} )

#
# find sbsolute path to all libraries 
# some are optionally, some may not exist on Linux
# 
FIND_LIBRARY(OpenCV_CORE_LIBRARY   
  NAMES opencv_core opencv_core220
  PATHS ${OpenCV_ROOT_DIR}  
  PATH_SUFFIXES  ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_IMGPROC_LIBRARY
  NAMES opencv_imgproc opencv_imgproc220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_HIGHGUI_LIBRARY  
  NAMES opencv_highgui opencv_highgui220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_ML_LIBRARY   
  NAMES opencv_ml opencv_ml220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_FEATURES2D_LIBRARY  
  NAMES opencv_features2d opencv_features2d220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_VIDEO_LIBRARY  
  NAMES opencv_video opencv_video220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_OBJDETECT_LIBRARY  
  NAMES opencv_objdetect opencv_objdetect220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_CALIB3D_LIBRARY  
  NAMES opencv_calib3d opencv_calib3d220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_FLANN_LIBRARY  
  NAMES opencv_flann opencv_flann220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_CONTRIB_LIBRARY  
  NAMES opencv_contrib opencv_contrib220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_LEGACY_LIBRARY  
  NAMES opencv_legacy opencv_legacy220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )
FIND_LIBRARY(OpenCV_GPU_LIBRARY  
  NAMES opencv_gpu opencv_gpu220
  PATHS ${OpenCV_ROOT_DIR}  PATH_SUFFIXES ${OpenCV_LIBDIR_SUFFIXES} )


#
# Logic selecting required libs and headers
#
SET(OpenCV_FOUND ON)
SET(OpenCV_INCLUDE_DIR ${OpenCV_CV_INCLUDE_DIR} )
FOREACH(NAME ${OpenCV_FIND_REQUIRED_COMPONENTS} )
  # only good if header and library both found   
  IF (OpenCV_${NAME}_INCLUDE_DIR AND OpenCV_${NAME}_LIBRARY)
#    LIST(APPEND OpenCV_INCLUDE_DIR ${OpenCV_${NAME}_INCLUDE_DIR} )
    LIST(APPEND OpenCV_LIBRARIES ${OpenCV_${NAME}_LIBRARY} )
    #MESSAGE(STATUS "Found: ${NAME}, includes: ${OpenCV_${NAME}_INCLUDE_DIR}, libraries: ${OpenCV_${NAME}_LIBRARY}")
  ELSE (OpenCV_${NAME}_INCLUDE_DIR AND OpenCV_${NAME}_LIBRARY)
    SET(OpenCV_FOUND OFF)
    MESSAGE(STATUS "Missing Required Component: ${NAME}, includes: ${OpenCV_${NAME}_INCLUDE_DIR}, libraries: ${OpenCV_${NAME}_LIBRARY}")
  ENDIF (OpenCV_${NAME}_INCLUDE_DIR AND OpenCV_${NAME}_LIBRARY)
ENDFOREACH(NAME)

# get the link directory for rpath to be used with LINK_DIRECTORIES: 
IF (OpenCV_CV_LIBRARY)
  GET_FILENAME_COMPONENT(OpenCV_LINK_DIRECTORIES ${OpenCV_CV_LIBRARY} PATH)
ENDIF (OpenCV_CV_LIBRARY)

# CORE IMGPROC HIGHGUI ML FEATURES2D VIDEO OBJDETECT CALIB3D FLANN CONTRIB LEGACY GPU
MARK_AS_ADVANCED(
  OpenCV_ROOT_DIR
  OpenCV_CV_INCLUDE_DIR
  OpenCV_CORE_INCLUDE_DIR
  OpenCV_IMGPROC_INCLUDE_DIR
  OpenCV_HIGHGUI_INCLUDE_DIR
  OpenCV_ML_INCLUDE_DIR
  OpenCV_FEATURES2D_INCLUDE_DIR
  OpenCV_VIDEO_INCLUDE_DIR
  OpenCV_OBJDETECT_INCLUDE_DIR
  OpenCV_CALIB3D_INCLUDE_DIR
  OpenCV_FLANN_INCLUDE_DIR
  OpenCV_CONTRIB_INCLUDE_DIR
  OpenCV_LEGACY_INCLUDE_DIR
  OpenCV_GPU_INCLUDE_DIR
  OpenCV_CORE_LIBRARY
  OpenCV_IMGPROC_LIBRARY
  OpenCV_HIGHGUI_LIBRARY
  OpenCV_ML_LIBRARY
  OpenCV_FEATURES2D_LIBRARY
  OpenCV_VIDEO_LIBRARY
  OpenCV_OBJDETECT_LIBRARY
  OpenCV_CALIB3D_LIBRARY
  OpenCV_FLANN_LIBRARY
  OpenCV_CONTRIB_LIBRARY
  OpenCV_LEGACY_LIBRARY
  OpenCV_GPU_LIBRARY
  )


# display help message
IF (NOT OpenCV_FOUND)
  # make FIND_PACKAGE friendly
  IF (NOT OpenCV_FIND_QUIETLY)
    IF(OpenCV_FIND_REQUIRED)
      MESSAGE(FATAL_ERROR "OpenCV required but some headers or libs not found. Please specify it's location with OpenCV_ROOT_DIR env. variable.")
    ELSE(OpenCV_FIND_REQUIRED)
      MESSAGE(STATUS "ERROR: OpenCV was not found.")
    ENDIF(OpenCV_FIND_REQUIRED)
  ENDIF(NOT OpenCV_FIND_QUIETLY)
ENDIF (NOT OpenCV_FOUND)

