# set preprocessor, compiler, linker flags
include(${CMAKE_CURRENT_LIST_DIR}/xpfunmac.cmake) # xp* functions, macros
include(${CMAKE_CURRENT_LIST_DIR}/pros.cmake) # xp_<project> lists
# trim flags that we've inherited
xpStringTrim(CMAKE_CXX_FLAGS)
xpStringTrim(CMAKE_C_FLAGS)
xpStringTrim(CMAKE_EXE_LINKER_FLAGS)
xpStringTrim(CMAKE_MODULE_LINKER_FLAGS)
xpStringTrim(CMAKE_SHARED_LINKER_FLAGS)
xpCommonFlags()
if(MSVC)
  # Debug Information Format: C7 compatible
  xpStringAppendIfDne(CMAKE_CXX_FLAGS_DEBUG "/Z7")
  xpStringAppendIfDne(CMAKE_C_FLAGS_DEBUG "/Z7")
endif()
#################
if(CMAKE_CONFIGURATION_TYPES)
  # http://www.cmake.org/Wiki/CMake_FAQ#How_can_I_specify_my_own_configurations_.28for_generators_that_allow_it.29_.3F
  # For generators that allow it (like Visual Studio), CMake generates four
  # configurations by default: Debug, Release, MinSizeRel and RelWithDebInfo.
  # Many people just need Debug and Release, or need other configurations. To
  # modify this change the variable CMAKE_CONFIGURATION_TYPES in the cache:
  set(CMAKE_CONFIGURATION_TYPES Debug Release)
  set(CMAKE_CONFIGURATION_TYPES "${CMAKE_CONFIGURATION_TYPES}" CACHE STRING
    "Set the configurations to what we need" FORCE
    )
endif(CMAKE_CONFIGURATION_TYPES)
xpStringTrim(CMAKE_CXX_FLAGS)
xpStringTrim(CMAKE_C_FLAGS)
xpStringTrim(CMAKE_EXE_LINKER_FLAGS)
xpStringTrim(CMAKE_MODULE_LINKER_FLAGS)
xpStringTrim(CMAKE_SHARED_LINKER_FLAGS)
