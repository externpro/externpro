set(file CMakePresetsBase.json)
if(EXISTS ${file})
  if(DEFINED presetSuffix)
    set(sfx ${presetSuffix})
  else()
    set(regex "^.*\"presetSuffix=(.*)\",?$")
    file(STRINGS ${file} sfx REGEX "${regex}")
    if(sfx)
      string(REGEX REPLACE "${regex}" "\\1" sfx ${sfx})
    endif()
  endif()
  if(DEFINED binaryDir)
    set(regex "^.*\"binaryDir\": \"(.*)\",?$")
    file(STRINGS ${file} var REGEX "${regex}")
    string(REGEX REPLACE "${regex}" "\\1" var ${var})
    file(READ ${file} presetsBase)
    string(REPLACE "${var}" "${binaryDir}" modPresetsBase "${presetsBase}")
    file(WRITE ${file} "${modPresetsBase}")
    if(NOT "${presetsBase}" STREQUAL "${modPresetsBase}")
      set(mod TRUE)
    endif()
  endif()
endif()
if(DEFINED ENV{JETPACK})
  set(presetName JetPack)
else()
  set(presetName ${CMAKE_HOST_SYSTEM_NAME})
endif()
if(DEFINED preset)
  if(preset STREQUAL "configure")
    execute_process(COMMAND ${CMAKE_COMMAND} --preset=${presetName})
  elseif(preset STREQUAL "build")
    execute_process(COMMAND ${CMAKE_COMMAND} --preset=${presetName})
    execute_process(COMMAND ${CMAKE_COMMAND} --preset=${presetName})
    execute_process(COMMAND ${CMAKE_COMMAND} --build --preset=${presetName}${sfx})
  elseif(preset STREQUAL "test")
    execute_process(COMMAND ${CMAKE_CTEST_COMMAND} --preset=${presetName}${sfx})
  elseif(preset STREQUAL "package")
    execute_process(COMMAND ${CMAKE_CPACK_COMMAND} --preset=${presetName}${sfx})
  elseif(preset STREQUAL "workflow")
    execute_process(COMMAND ${CMAKE_COMMAND} --preset=${presetName})
    execute_process(COMMAND ${CMAKE_COMMAND} --workflow --preset=${presetName}${sfx})
  else()
    message(AUTHOR_WARNING "preset not supported: ${preset}, executing 'configure'")
    execute_process(COMMAND ${CMAKE_COMMAND} --preset=${presetName})
  endif()
else()
  execute_process(COMMAND ${CMAKE_COMMAND} --preset=${presetName})
endif()
if(mod)
  file(WRITE ${file} "${presetsBase}")
endif()
