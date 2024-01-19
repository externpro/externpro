# set cmake variables prior to project()
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  # NOTE: CMAKE_INSTALL_PREFIX must be set before project() to take effect
  set(CMAKE_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/dist CACHE PATH
    "Install path prefix, prepended onto install directories."
    )
endif()
if(CMAKE_CONFIGURATION_TYPES)
  # https://gitlab.kitware.com/cmake/community/wikis/FAQ#how-can-i-specify-my-own-configurations-for-generators-that-allow-it-
  # For generators that allow it (like Visual Studio), CMake generates four
  # configurations by default: Debug, Release, MinSizeRel and RelWithDebInfo.
  # Many people just need Debug and Release, or need other configurations. To
  # modify this change the variable CMAKE_CONFIGURATION_TYPES in the cache:
  set(CMAKE_CONFIGURATION_TYPES Debug Release)
  set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING
    "Set the configurations to what we need" FORCE
    )
  # NOTE: It appears that there is a cmake bug - the configuration settings
  # only take effect by running cmake twice ('cmake ..' then 'cmake .')
  # http://www.cmake.org/pipermail/cmake/2008-April/020993.html
  # http://public.kitware.com/Bug/view.php?id=5811
endif()
