if(NOT EXISTS ${dst})
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory ${dst})
endif()
separate_arguments(src)
foreach(item ${src})
  get_filename_component(itemDir ${item} DIRECTORY)
  if(NOT EXISTS ${itemDir})
    return()
  endif()
  file(GLOB files ${item})
  foreach(f ${files})
    if(IS_DIRECTORY ${f})
      execute_process(COMMAND ${CMAKE_COMMAND} -E copy_directory ${f} ${dst})
    else()
      execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${f} ${dst})
    endif()
  endforeach()
endforeach()
