cmake_minimum_required(VERSION 2.6.0)
PROJECT( UBITRACK )
#SET(CMAKE_CXX_COMPILER "/opt/local/bin/g++")
MESSAGE(STATUS ${CMAKE_CXX_COMPILER})

# Global Cmake Modules
SET(CMAKE_MODULE_PATH "${UBITRACK_SOURCE_DIR}/cmake" )

# Needs to find module directories automatically ..
SET(components utcore)

FOREACH(component ${components})
  IF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/modules/${component})
    MESSAGE( STATUS "Including ${component}" )
    SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${UBITRACK_SOURCE_DIR}/modules/${component}/cmake" )
    ADD_SUBDIRECTORY(modules/${component})
  ENDIF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/modules/${component})
ENDFOREACH(component)
