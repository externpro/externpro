# generate a version.js/ts file
# @param[in] P_VERSION_DEST : Where to put the version.js/ts file
# @param[in] VERSION_TARGET : What to name the target
# @param[in] REVISION_TXT : Where the revision.txt file is located
if(NOT DEFINED REVISION_TXT)
  message(FATAL_ERROR "REVISION_TXT must be set before including versionjs.cmake")
endif()
if(NOT DEFINED P_VERSION_DEST)
  message(FATAL_ERROR "P_VERSION_DEST must be set before including versionjs.cmake")
endif()
if(EXISTS ${REVISION_TXT})
  file(READ ${REVISION_TXT} gitRevision)
  string(STRIP ${gitRevision} gitRevision)
else()
  set(gitRevision "unknown-revision")
endif()
configure_file(${CMAKE_CURRENT_BINARY_DIR}/version.es.in ${CMAKE_CURRENT_SOURCE_DIR}/${P_VERSION_DEST} NEWLINE_STYLE LF)
# do the following at cmake-time so the VERSION_TARGET target exists at build-time
if(NOT TARGET ${VERSION_TARGET} AND DEFINED CMAKE_SYSTEM_NAME)
  add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${VERSION_TARGET}.stamp
    COMMAND ${CMAKE_COMMAND}
      -DP_VERSION_DEST:FILEPATH="${P_VERSION_DEST}"
      -DREVISION_TXT:FILEPATH="${REVISION_TXT}"
      -DVERSION_TARGET="${VERSION_TARGET}"
      -P ${CMAKE_CURRENT_LIST_FILE}
    COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/${VERSION_TARGET}.stamp
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    COMMENT "Generating ${P_VERSION_DEST}..."
    DEPENDS Revision_hpp
    )
  add_custom_target(${VERSION_TARGET}
    SOURCES ${REVISION_TXT} ${CMAKE_CURRENT_LIST_FILE}
    DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${VERSION_TARGET}.stamp
    )
  set_target_properties(${VERSION_TARGET} PROPERTIES FOLDER CMakeTargets STAMP ${VERSION_TARGET}.stamp)
endif()
