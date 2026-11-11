# fixture for ipCpsRequiresGlobalConflict (xpfunmac.cmake): does a CPS
# "requires" dep whose imported target was created GLOBAL in another
# directory get flagged (FIND_PACKAGE_CMAKE_SCRIPT) to force the
# config-script route? see https://github.com/externpro/externpro/issues/356
cmake_minimum_required(VERSION 3.23)
project(cps-requires-global NONE)
if(NOT DEFINED XPFUNMAC)
  set(XPFUNMAC ${CMAKE_CURRENT_SOURCE_DIR}/../../cmake/xpfunmac.cmake)
endif()
if(NOT EXISTS ${XPFUNMAC})
  message(FATAL_ERROR "xpfunmac.cmake not found: ${XPFUNMAC} (set -DXPFUNMAC=<path>)")
endif()
include(${XPFUNMAC})
set(P ${CMAKE_SOURCE_DIR}/pkgs)

# SCENARIO selects where dep::dep gets created (if at all)
add_subdirectory(sub)
if(SCENARIO STREQUAL "same_dir")
  add_library(dep::dep INTERFACE IMPORTED GLOBAL)
endif()

macro(check scenario expect)
  unset(FIND_PACKAGE_CMAKE_SCRIPT)
  ipCpsRequiresGlobalConflict(${ARGN})
  # second call exercises the IP_CPSREQ_ cache path
  ipCpsRequiresGlobalConflict(${ARGN})
  if(DEFINED FIND_PACKAGE_CMAKE_SCRIPT)
    set(got SET)
  else()
    set(got unset)
  endif()
  if("${got}" STREQUAL "${expect}")
    message(STATUS "PASS ${scenario}: flag ${got}")
  else()
    message(SEND_ERROR "FAIL ${scenario}: flag ${got} (expected ${expect})")
  endif()
endmacro()

if(SCENARIO STREQUAL "other_dir")
  # pkgs/req has a share/cmake/*onfig.cmake fallback -> flag must be SET
  check("global-dep-in-subdir+config-fallback" SET ${P}/req req)
  # pkgs/reqnocfg has only a .cps -- no script route exists -> no flag
  check("global-dep-in-subdir+no-fallback" unset ${P}/reqnocfg reqnocfg)
elseif(SCENARIO STREQUAL "same_dir")
  check("global-dep-created-here" unset ${P}/req req)
elseif(SCENARIO STREQUAL "no_dep")
  check("no-dep-target" unset ${P}/req req)
elseif(SCENARIO STREQUAL "local_dep")
  check("local-dep-in-subdir-invisible" unset ${P}/req req)
else()
  message(FATAL_ERROR "unknown SCENARIO='${SCENARIO}'")
endif()
