# usage: from the .devcontainer/ directory
# command to get a list of projects with devel packages (have TAG) that have been modified in cmake/pros.cmake since the 25.01 tag
#  git diff 25.01 HEAD -- pros.cmake | grep "+set(xp_" | grep TAG | sed 's/+set(xp_//' | cut -d" " -f1
# create sync scripts for all the projects that have been changed
#  git diff 25.01 HEAD -- pros.cmake | grep "+set(xp_" | grep TAG | sed 's/+set(xp_//' | cut -d" " -f1 | xargs cmake -P cmake/sync.cmake --
# create a specific sync script
#  cmake -P cmake/sync.cmake -- zlib
# create multiple sync scripts
#  cmake -P cmake/sync.cmake -- zlib palam
function(generateSyncScript)
  set(options XP_MODULE)
  set(reqArgs PKG BRANCH REPO TAG SHA256_Linux SHA256_Linux-arm64 SHA256_win64)
  set(oneValueArgs ${reqArgs} BASE DESC DIST_DIR LICENSE UPSTREAM VER WEB XPBLD)
  list(APPEND oneValueArgs SHA256_Darwin-arm64) # TODO move to reqArgs once all projects have Darwin build
  list(APPEND oneValueArgs URL_Darwin-arm64 URL_Linux URL_Linux-arm64 URL_win64 SHA256_utres)
  set(multiValueArgs DEPS EXE_DEPS)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  foreach(arg ${reqArgs})
    if(NOT DEFINED P_${arg})
      message(FATAL_ERROR "generateSyncScript: ${P_PKG} missing required argument: ${arg}")
    endif()
  endforeach()
  execute_process(COMMAND ${CMAKE_COMMAND} -E echo '${P_REPO}' COMMAND cut -d/ -f2 OUTPUT_VARIABLE P_ORG OUTPUT_STRIP_TRAILING_WHITESPACE)
  if(DEFINED P_SHA256_utres)
    set(moreCowbell "\ndownloadAndCompare Unit_Test_Results.tar.xz ${P_SHA256_utres}")
  endif()
  if(DEFINED P_SHA256_Darwin-arm64)
    set(moreCowbell "${moreCowbell}\ndownloadAndCompare ${P_PKG}-${P_TAG}-Darwin-arm64-devel.tar.xz ${P_SHA256_Darwin-arm64}")
  endif()
  configure_file(${CMAKE_CURRENT_LIST_DIR}/sync.sh.in Sync${P_PKG}.sh)
endfunction()
include(${CMAKE_CURRENT_LIST_DIR}/pros.cmake)
math(EXPR argIdx "${CMAKE_ARGC}-1")
foreach(n RANGE 4 ${argIdx}) # cmake[ARGV0] -P[ARGV1] path/to/sync.cmake[ARGV2] --[ARGV3]
  generateSyncScript(PKG ${CMAKE_ARGV${n}} ${xp_${CMAKE_ARGV${n}}})
endforeach()
