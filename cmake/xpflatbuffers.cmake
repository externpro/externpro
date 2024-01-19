function(xpFlatBuffersBuild)
  set(options PUBLIC_INCLUDES)
  set(oneValueArgs TARGET CUSTOM_TARGET_NAME GENERATED_INCLUDES_DIR BINARY_SCHEMAS_DIR COPY_TEXT_SCHEMAS_DIR)
  set(multiValueArgs SCHEMAS SCHEMA_INCLUDE_DIRS ADDITIONAL_DEPS)
  cmake_parse_arguments(P "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  if(NOT P_CUSTOM_TARGET_NAME)
    if(P_TARGET)
      set(P_CUSTOM_TARGET_NAME ${P_TARGET}_fbs)
    else()
      set(P_CUSTOM_TARGET_NAME ${PROJECT_NAME}_fbs)
    endif()
  endif()
  if(NOT P_GENERATED_INCLUDES_DIR)
    set(P_GENERATED_INCLUDES_DIR ${CMAKE_CURRENT_BINARY_DIR}/fbs)
  endif()
  build_flatbuffers("${P_SCHEMAS}" "${P_SCHEMA_INCLUDE_DIRS}" ${P_CUSTOM_TARGET_NAME}
    "${P_ADDITIONAL_DEPS}" "${P_GENERATED_INCLUDES_DIR}"
    "${P_BINARY_SCHEMAS_DIR}" "${P_COPY_TEXT_SCHEMAS_DIR}"
    )
  if(P_TARGET)
    if(P_PUBLIC_INCLUDES)
      set(scope PUBLIC)
    else()
      set(scope PRIVATE)
    endif()
    add_dependencies(${P_TARGET} ${P_CUSTOM_TARGET_NAME})
    target_include_directories(${P_TARGET} ${scope} ${P_GENERATED_INCLUDES_DIR})
  endif()
endfunction()

function(xpFlatBuffersBuildTS)
  set(oneValueArgs OUTPUT_DIR TARGET)
  set(multiValueArgs SCHEMAS)
  cmake_parse_arguments(P "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  xpGetPkgVar(flatbuffers FLATC_EXECUTABLE) # sets FLATBUFFERS_FLATC_EXECUTABLE
  set(cmdFile "${CMAKE_CURRENT_BINARY_DIR}/${P_TARGET}_fbs_ts_cmd")
  file(GLOB schemas ${P_SCHEMAS})
  add_custom_command(OUTPUT ${cmdFile}
    COMMAND $<TARGET_FILE:${FLATBUFFERS_FLATC_EXECUTABLE}> --ts -o ${P_OUTPUT_DIR} ${schemas}
    COMMAND ${CMAKE_COMMAND} -E touch ${cmdFile}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    DEPENDS ${schemas}
    )
  set(tgtName ${P_TARGET}_fbs_ts)
  add_custom_target(${tgtName} ALL DEPENDS ${cmdFile})
  set_target_properties(${tgtName} PROPERTIES FOLDER ${folder} STAMP ${cmdFile})
endfunction()
