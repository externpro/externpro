# set cmake variables prior to project()
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # NOTE: CMAKE_INSTALL_PREFIX must be set before project() to take effect
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/dist CACHE PATH
    "Install path prefix, prepended onto install directories."
    )
endif()
macro(externpro_provide_dependency method depName)
  if(${method} STREQUAL "FIND_PACKAGE")
    xpFindPkg(PKGS ${depName})
  endif()
endmacro()
cmake_language(
  SET_DEPENDENCY_PROVIDER externpro_provide_dependency
  SUPPORTED_METHODS FIND_PACKAGE
  )
