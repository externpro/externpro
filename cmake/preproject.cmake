# set cmake variables prior to project()
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # NOTE: CMAKE_INSTALL_PREFIX must be set before project() to take effect
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/dist CACHE PATH
    "Install path prefix, prepended onto install directories."
    )
endif()
