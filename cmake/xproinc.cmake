# set cmake variables prior to project()
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # NOTE: CMAKE_INSTALL_PREFIX must be set before project() to take effect
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/dist CACHE PATH
    "Install path prefix, prepended onto install directories."
    )
endif()
if(DEFINED XPRO_DIR)
  message(DEPRECATION "XPRO_DIR is no longer used; downloads now go to XPD_DIR \
(default ~/.cache/externpro) and extracted packages to <binary-dir>/_xpx"
    )
endif()
if(NOT DEFINED XPD_DIR)
  if(DEFINED ENV{XPD_DIR})
    set(_xpd "$ENV{XPD_DIR}")
  elseif(WIN32 AND DEFINED ENV{LOCALAPPDATA})
    set(_xpd "$ENV{LOCALAPPDATA}/externpro")
  elseif(DEFINED ENV{XDG_CACHE_HOME})
    set(_xpd "$ENV{XDG_CACHE_HOME}/externpro")
  elseif(DEFINED ENV{HOME})
    set(_xpd "$ENV{HOME}/.cache/externpro")
  else()
    set(_xpd "${CMAKE_BINARY_DIR}/_xpd")
    message(WARNING "XPD_DIR: no HOME/LOCALAPPDATA; falling back to build-dir cache")
  endif()
  set(XPD_DIR "${_xpd}" CACHE PATH
    "externpro download cache (downloaded manifests, pkgs)"
    )
endif()
list(FIND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR} idx)
if(idx EQUAL -1)
  list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
endif()
include(pros) # projects/dependencies externpro provides by default (xp_<project>)
macro(externpro_provide_dependency method depName)
  if(${method} STREQUAL "FIND_PACKAGE")
    xpFindPkg(PKGS ${depName})
    if(NOT ${depName}_FOUND)
      find_package(${depName} BYPASS_PROVIDER ${ARGN})
    endif()
  endif()
endmacro()
cmake_language(
  SET_DEPENDENCY_PROVIDER externpro_provide_dependency
  SUPPORTED_METHODS FIND_PACKAGE
  )
set(CMAKE_PROJECT_INCLUDE xpflags;GNUInstallDirs)
