# set cmake variables prior to project()
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # NOTE: CMAKE_INSTALL_PREFIX must be set before project() to take effect
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/dist CACHE PATH
    "Install path prefix, prepended onto install directories."
    )
endif()
if(NOT DEFINED XPRO_DIR)
  set(XPRO_DIR ${CMAKE_BINARY_DIR}/_xpro CACHE PATH
    "externpro working directory (downloaded manifests, pkgs; extracted xpro pkgs)"
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
