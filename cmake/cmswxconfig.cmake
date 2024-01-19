# @param[in] cfgDir : <BINARY_DIR>/lib/wx/config
# @param[in] stgDir : ${STAGE_DIR}
file(GLOB cfgFiles ${cfgDir}/[^inplace]*)
# copy the first file in the list
list(GET cfgFiles 0 cfgFile)
get_filename_component(cfgFile ${cfgFile} ABSOLUTE)
get_filename_component(binDir ${stgDir}/bin ABSOLUTE)
get_filename_component(libDir ${stgDir}/lib/wx/config ABSOLUTE)
if(NOT EXISTS ${binDir})
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${binDir})
endif()
if(NOT EXISTS ${libDir})
  message(SEND_ERROR "wxconfig.cmake: lib directory should already exist: ${libDir}")
endif()
# rename to wx-config in the bin directory
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${cfgFile} ${binDir}/wx-config)
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${cfgFile} ${libDir})
