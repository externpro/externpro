# externpro machinery tests: verify xpfunmac internals against fixture projects
#   standalone: cmake -S test -B bld && ctest --test-dir bld
#   vendored:   buildpro adds this dir via add_subdirectory(.externpro/test xptest)
cmake_minimum_required(VERSION 4.0)
if(NOT DEFINED PROJECT_NAME)
  project(xptest NONE)
  enable_testing()
endif()
cmake_path(SET XP_FUNMAC NORMALIZE ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/xpfunmac.cmake)
set(fxt ${CMAKE_CURRENT_SOURCE_DIR}/cps-requires-global)
# each scenario configures the fixture; the fixture SEND_ERRORs on failure
# (a nonzero cmake configure = failed test)
#   other_dir: dep::dep created GLOBAL in a sibling dir -> conflict flagged
#   same_dir:  dep::dep created GLOBAL in this dir -> in local map, no flag
#   no_dep:    dep::dep doesn't exist -> no flag
#   local_dep: dep::dep created non-global in a sibling dir -> invisible, no flag
foreach(scn other_dir same_dir no_dep local_dep)
  add_test(NAME cpsreq-${scn}
    COMMAND ${CMAKE_COMMAND} -S ${fxt} -B ${CMAKE_CURRENT_BINARY_DIR}/bld-${scn}
      -DSCENARIO=${scn} -DXPFUNMAC=${XP_FUNMAC}
    )
endforeach()
