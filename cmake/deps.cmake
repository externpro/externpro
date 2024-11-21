function(proDeps)
  set(options XP_MODULE)
  set(oneValueArgs PKG BASE BRANCH DIST_DIR REPO TAG SHA256_Linux SHA256_win64 URL_Linux URL_win64 SHA256_utres)
  set(multiValueArgs DEPS EXE_DEPS)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  string(APPEND dot "  \"${P_PKG}\" [shape=diamond]\;\n")
  if(DEFINED P_DEPS OR DEFINED P_EXE_DEPS)
    foreach(dep ${P_DEPS} ${P_EXE_DEPS})
      string(APPEND dot "  \"${P_PKG}\" -> \"${dep}\"\;\n")
    endforeach()
  endif()
  set(dot "${dot}" PARENT_SCOPE)
endfunction()

string(JOIN "\n" dot
  "digraph GG {"
  "  node [fontsize=12]\;"
  ""
  )
include(${CMAKE_CURRENT_LIST_DIR}/pros.cmake)
# https://stackoverflow.com/q/9298278/
get_cmake_property(vars VARIABLES)
list(SORT vars)
foreach(var ${vars})
  if(var MATCHES "^xp_")
    string(REGEX REPLACE "^xp_" "" pkg ${var})
    proDeps(PKG ${pkg} ${${var}})
  endif()
endforeach()
string(APPEND dot "}\n")
file(WRITE deps.dot ${dot})
