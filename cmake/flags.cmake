# set preprocessor, compiler, linker flags
include(${CMAKE_CURRENT_LIST_DIR}/xpfunmac.cmake) # xp* functions, macros
# trim flags that we've inherited
xpStringTrim(CMAKE_CXX_FLAGS)
xpStringTrim(CMAKE_C_FLAGS)
xpStringTrim(CMAKE_EXE_LINKER_FLAGS)
xpStringTrim(CMAKE_MODULE_LINKER_FLAGS)
xpStringTrim(CMAKE_SHARED_LINKER_FLAGS)
xpCommonFlags()
if(MSVC)
  # Debug Information Format: C7 compatible
  add_compile_options($<$<COMPILE_LANGUAGE:CXX,C>:$<$<CONFIG:Debug>:/Z7>>)
endif()
xpStringTrim(CMAKE_CXX_FLAGS)
xpStringTrim(CMAKE_C_FLAGS)
xpStringTrim(CMAKE_EXE_LINKER_FLAGS)
xpStringTrim(CMAKE_MODULE_LINKER_FLAGS)
xpStringTrim(CMAKE_SHARED_LINKER_FLAGS)
